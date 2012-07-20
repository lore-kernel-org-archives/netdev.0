From: hayeswang <hayeswang@realtek.com>
Subject: RE: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Fri, 20 Jul 2012 15:14:26 +0800
Message-ID: <EF06A7B3C1E6432BB660CDEF8E1D2A1B@realtek.com.tw>
References: <20120718.132840.1571938255177607234.davem@davemloft.net><20120718214422.GA18207@electric-eye.fr.zoreil.com><1342649136.2626.3757.camel@edumazet-glaptop> <20120718.152405.1083396282134539674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:45065 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab2GTHOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 03:14:38 -0400
In-Reply-To: <20120718.152405.1083396282134539674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Francois Romieu <romieu@fr.zoreil.com>

> >> > A NETDEV_TX_OK return means we accepted the SKB, it 
> doesn't look like
> >> > that's what you are doing in the skb_padto() failure path.
> >> 
> >> ?
> >> 
> >> - skb_padto fails
> >>   (original skb is implicitely freed)
> >> - skb_padto returns error status (!= 0)
> >> - rtl8169_tso_csum returns false
> >> - start_xmit returns NETDEV_TX_OK. 
> >> 
> >> I'll search the missing "!" after some sleep if that's 
> what you are talking
> >> about. Otherwise than that, I don't get it.
> >> 
> > 
> > 
> > Yes, I believe your patch is fine.
> > 
> > In fact many drivers dont account the error in their stats.
> 
> My bad, I forgot that skb_padto() frees the SKB on failure.
> 

I find that the total length field of IP header would be modified if the hw
checksum is enabled. Therefore, skb_padto + hw checksum wouldn't work. The
software checksum is necessary.
 
Best Regards,
Hayes
