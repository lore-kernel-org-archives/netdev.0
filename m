From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2] mpls: reduce memory usage of routes
Date: Tue, 27 Oct 2015 18:39:20 -0700
Message-ID: <56302748.7050209@cumulusnetworks.com>
References: <1445906256-14927-1-git-send-email-rshearma@brocade.com> <1445906256-14927-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35903 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbJ1BjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 21:39:20 -0400
Received: by pacfv9 with SMTP id fv9so250041737pac.3
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 18:39:20 -0700 (PDT)
In-Reply-To: <1445906256-14927-3-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/15, 5:37 PM, Robert Shearman wrote:
> Nexthops for MPLS routes have a via address field sized for the
> largest via address that is expected, which is 32 bytes. This means
> that in the most common case of having ipv4 via addresses, 28 bytes of
> memory more than required are used per nexthop. In the other common
> case of an ipv6 nexthop then 16 bytes more than required are
> used. With large numbers of MPLS routes this extra memory usage could
> start to become significant.
>
> To avoid allocating memory for a maximum length via address when not
> all of it is required and to allow for ease of iterating over
> nexthops, then the via addresses are changed to be stored in the same
> memory block as the route and nexthops, but in an array after the end
> of the array of nexthops. New accessors are provided to retrieve a
> pointer to the via address.
>
> To allow for O(1) access without having to store a pointer or offset
> per nh, the via address for each nexthop is sized according to the
> maximum via address for any nexthop in the route, which is stored in a
> new route field, rt_max_alen, but this is in an existing hole in
> struct mpls_route so it doesn't increase the size of the
> structure. Each via address is ensured to be aligned to VIA_ALEN_ALIGN
> to account for architectures that don't allow unaligned accesses.
>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
nice way to handle it!. I was going to submit a patch to make MAX_VIA_ALEN = 16bytes as suggested by Eric.
In which case, your patch will only help the case where all nexthops are ipv4.
