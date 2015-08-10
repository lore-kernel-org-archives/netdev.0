From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: track link status of ipv6 nexthops
Date: Mon, 10 Aug 2015 14:46:52 -0400
Message-ID: <20150810184651.GL504@gospo.home.greyhouse.net>
References: <1438875754-28025-1-git-send-email-gospo@cumulusnetworks.com>
 <20150810.105400.1277861088010551746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33738 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932375AbbHJSq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 14:46:58 -0400
Received: by ykaz130 with SMTP id z130so39898306yka.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 11:46:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150810.105400.1277861088010551746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2015 at 10:54:00AM -0700, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Thu,  6 Aug 2015 11:42:33 -0400
> 
> > Add support to track current link status of ipv6 nexthops to match
> > recent changes that added support for ipv4 nexthops.  There was not a
> > field already available that could track these and no space available in
> > the existing rt6i_flags field, so this patch adds rt6i_nhflags to struct
> > rt6_info.
> > 
> > Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> > Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> 
> This doesn't really make any sense to me.
> 
> You can evaluate the state of the link at the time you look at the
> route at all of the places where it matters as far as I can tell.
> 
> It's so expensive to walk the entire routing table every time a link
> goes up and down, so it's much better to take an "evaluate as needed"
> approach to implementing this.

I went this way as the idea of storing this info in a flags structure
for 2 reasons:

- This idea or marking on link status changes and checking for that mark
  during forwarding was done what was suggested by Alex et al for the
  ipv4 code and I wanted to keep the overall design similar.

- New flags will likely be needed when switchdev support is added for
  ipv6 routes so going ahead and mirroring the RTNH_F* flags in the the
  ipv6 code seemed reasonable.

I would actually be fine with what you proposed (it is closer to the
first implementation), so if my justification above does not change your
mind, let me know and I'll post a v2 that does not add rt6i_nhflags and
simply checks netif_carrier_ok() rather than RTNH_F_LINKDOWN.
