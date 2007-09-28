From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e1000 tcp checksum incorrect, x86 64b
Date: Fri, 28 Sep 2007 12:08:16 +0800
Message-ID: <E1Ib79E-0006CN-00@gondolin.me.apana.org.au>
References: <9e4733910709272050t65e76312k52fd7493b899071d@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: jonsmirl@gmail.com (Jon Smirl)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4521 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751204AbXI1EIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 00:08:21 -0400
In-Reply-To: <9e4733910709272050t65e76312k52fd7493b899071d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Smirl <jonsmirl@gmail.com> wrote:
>
> App is writing seven bytes to the socket. Socket write timeout expires
> and the seven bytes are sent. The checksum is not getting inserted
> into the packet. It is set to a constant 0x8389 instead of the right
> value.  App is gmpc 0.15.4.95, Revision: 6794
> 
> Attached Wireshark packet trace show the problem. e1000 is 192.168.1.4
> 64bit, Q6600. Dell Dimension 9200

Wireshark is broken.  It needs to know TP_STATUS_CSUMNOTREADY
means that the checksum is partial and will only be completed
when the hardware sends the packet out.

Alternatively disable checksum offload with ethtool.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
