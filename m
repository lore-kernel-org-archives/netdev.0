From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: original ingress device index in
 PKTINFO
Date: Sat, 7 May 2016 22:08:30 +0300
Message-ID: <20160507220830.14cf9b64@halley>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
	<1462585781-9146-3-git-send-email-dsa@cumulusnetworks.com>
	<20160507114148.347716e4@halley>
	<572E0178.4010601@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33935 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcEGTIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 15:08:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id n129so13911477wmn.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 12:08:36 -0700 (PDT)
In-Reply-To: <572E0178.4010601@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, 7 May 2016 08:53:44 -0600 David Ahern <dsa@cumulusnetworks.com> wrote:
> >> @@ -1193,7 +1193,12 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
> >>   		       ipv6_sk_rxinfo(sk);
> >>
> >>   	if (prepare && skb_rtable(skb)) {
> >> -		pktinfo->ipi_ifindex = inet_iif(skb);
> >> +		/* skb->cb is overloaded: prior to this point it is IP{6}CB
> >> +		 * which has interface index (iif) as the first member of the
> >> +		 * underlying inet{6}_skb_parm struct. This code then overlays
> >> +		 * PKTINFO_SKB_CB and in_pktinfo also has iif as the first
> >> +		 * element so the iif is picked up from the prior IPCB
> >> +		 */  
> >
> > Better if there was a guarantee in the code that inet_skb_parm layout stays
> > that way. Or instead just explicitly assign the iif.  
> 
> At this point inet_iif points to the vrf device so can't use it.

Initially I was thinking about explicitly getting the iif out of the
IPCB first, then assign to ipi_ifindex. Seems more readable, and less
fragile. However this depends on the IPCB/IP6CB layout relationship as
well (iif being first on both).

I assume documenting the IP{6}CB/PKTINFO_SKB_CB layout relationship at the
struct definitions would be beneficial.

Regards,
Shmulik
