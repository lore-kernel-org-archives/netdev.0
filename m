From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Mon, 19 Oct 2015 10:01:59 +0200
Message-ID: <20151019080159.GK7701@secunet.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com>
 <20151009071710.GJ7701@secunet.com>
 <5617F908.8060807@cumulusnetworks.com>
 <561C00B9.1020301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hajime Tazaki <thehajime@gmail.com>, <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43859 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbbJSICE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 04:02:04 -0400
Content-Disposition: inline
In-Reply-To: <561C00B9.1020301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 12:49:29PM -0600, David Ahern wrote:
> On 10/9/15 11:27 AM, David Ahern wrote:
> >On 10/9/15 1:17 AM, Steffen Klassert wrote:
> >>>>diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> >>>>index 30caa289c5db..5cedfda4b241 100644
> >>>>--- a/net/ipv6/xfrm6_policy.c
> >>>>+++ b/net/ipv6/xfrm6_policy.c
> >>>>@@ -37,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct
> >>>>net *net, int tos, int oif,
> >>>>
> >>>>      memset(&fl6, 0, sizeof(fl6));
> >>>>      fl6.flowi6_oif = oif;
> >>>>+    fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
> >>>>      memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
> >>>>      if (saddr)
> >>>>          memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
> >>>
> >>>I found that this fix is still not sufficient with the mip6
> >>>(Mobile IPv6) use case.
> >>
> >>It does not even fix the vti case. The behaviour of the vti devices is
> >>the same, with and without the patch.
> >>
> >
> >The attached patch applied to Linus' tree works for me. Currently the
> >above change is not in his tree, so I added it to this patch. Once you
> >confirm that it works for you I'll create the delta-patch for net and
> >send out.
> 
> Steffen: Have you had a chance to try the patch? Does it solve the
> vti6 problem for you?

The delta of your patch and the current net tree fixes the
vti6 problems.

Current net-next works without any changes.

Thanks David!
