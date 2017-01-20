From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: error out on multiple via without
 nexthop keyword
Date: Fri, 20 Jan 2017 09:38:09 -0800
Message-ID: <20170120093809.5f771c4f@xeon-e3>
References: <1484845701-19354-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33016 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbdATRiM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:38:12 -0500
Received: by mail-pg0-f41.google.com with SMTP id 204so25225943pge.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:38:12 -0800 (PST)
In-Reply-To: <1484845701-19354-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 09:08:21 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> To specify multiple nexthops in a route the user is expected to use the
> "nexthop" keyword which ip route uses to create the RTA_MULTIPATH.
> However, ip route always accepts multiple 'via' keywords where only the
> last one is used in the route leading to confusion. For example, ip
> accepts this syntax:
>     $ ip ro add vrf red  1.1.1.0/24 via 10.100.1.18 via 10.100.2.18
> 
> but the route entered inserted by the kernel is just the last gateway:
>     1.1.1.0/24 via 10.100.2.18 dev eth2
> 
> which is not the full request from the user. Detect the presense of
> multiple 'via' and give the user a hint to add nexthop:
> 
>     $ ip ro add vrf red  1.1.1.0/24 via 10.100.1.18 via 10.100.2.18
>     Error: argument "via" is wrong: use nexthop syntax to specify multiple via
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied thanks.
