From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: original ingress device index in
 PKTINFO
Date: Sat, 7 May 2016 11:41:48 +0300
Message-ID: <20160507114148.347716e4@halley>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
	<1462585781-9146-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35312 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbcEGIly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 04:41:54 -0400
Received: by mail-wm0-f66.google.com with SMTP id e201so12304845wme.2
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 01:41:53 -0700 (PDT)
In-Reply-To: <1462585781-9146-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri,  6 May 2016 18:49:41 -0700 David Ahern <dsa@cumulusnetworks.com> wrote:
> Applications such as OSPF and BFD need the original ingress device not
> the VRF device;

Would you consider this true for any IP_PKTINFO users in VRF setups?

> @@ -1193,7 +1193,12 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
>  		       ipv6_sk_rxinfo(sk);
>  
>  	if (prepare && skb_rtable(skb)) {
> -		pktinfo->ipi_ifindex = inet_iif(skb);
> +		/* skb->cb is overloaded: prior to this point it is IP{6}CB
> +		 * which has interface index (iif) as the first member of the
> +		 * underlying inet{6}_skb_parm struct. This code then overlays
> +		 * PKTINFO_SKB_CB and in_pktinfo also has iif as the first
> +		 * element so the iif is picked up from the prior IPCB
> +		 */

Better if there was a guarantee in the code that inet_skb_parm layout stays
that way. Or instead just explicitly assign the iif.

Regards,
Shmulik
