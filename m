From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: question about eth_header
Date: Tue, 20 Nov 2012 17:39:30 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1BF6DC59@SJEXCHMB06.corp.ad.broadcom.com>
References: <1353419044.16036.6.camel@lb-tlvb-dmitry>
 <CAKoUArnRnx0txGWhNWpZAFBijWmtzdOe-D7Qb62-5AvBCfgHJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rami Rosen" <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4528 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238Ab2KTRjy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 12:39:54 -0500
In-Reply-To: <CAKoUArnRnx0txGWhNWpZAFBijWmtzdOe-D7Qb62-5AvBCfgHJQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Rami Rosen
> Sent: Tuesday, November 20, 2012 4:51 PM
> To: Dmitry Kravkov
> Cc: netdev@vger.kernel.org
> Subject: Re: question about eth_header
> 
> Hi,
> I think that you should call skb_reset_mac_header()
> before calling eth_hdr() and that skb_reset_mac_header() should not be
> inside eth_hdr(). Following is explanation:
> 
> In the RX path, when we get a packet in the driver, what essentially
> happens is that at this point, we have a pointer to
> the packet buffer in skb->data, and its length in skb->len.

Actually I'm on TX path, and do not intend  to update skb, just received it 
for transmission, I want to pick mac addresess from eth header.
Now bnx2x does it by accessing skb->data (which points to the correct mac)
and I wanted to replace it with eth_hrd instead of doing ugly casting in driver code.
Moreover, in the future, when inner_mac_address will be used for tunneling
acceleration, inner_mac_address will be updated with mac_address offset, and so
may also point to the improper location.   
 
> With ethernet packets, the driver will call eth_type_trans(); please
> look at ethernet drivers code.
> eth_type_trans() indeed sets the MAC header pointer by calling
> skb_reset_mac_header() on the skb.
> 
> Afterwards, the eth_type_trans() will advance skb->data by
> 14, the size of the Ethernet header, and decrease skb->len
> by calling skb_pull_inline(skb, ETH_HLEN).
> 
> In case you are wondering why the skb_reset_mac_header() is not inside
> the eth_hdr(), I think that the reason is that, once
> skb_reset_mac_header() on the skb was called, there are cases when we
> want to make several calls eth_hdr() without each time again resetting
> the mac header, for example, in the bridging code.  There is no reason
> to doing it in terms of performance.

My question is about eth_header() function which is create() callback for
eth_header_ops.

Thanks.
