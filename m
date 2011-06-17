From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] fs_enet: fix freescale FCC ethernet dp buffer alignment
Date: Fri, 17 Jun 2011 11:16:24 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8ADA6@saturn3.aculab.com>
References: <007701cc2cce$42342320$2804000a@yangyong>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Clive Stubbings" <clive.stubbings@xentech.co.uk>,
	"Vitaly Bordug" <vbordug@ru.mvista.com>
To: <yangyong@neusoft.com>,
	"Holger Brunck" <holger.brunck@keymile.com>,
	<linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45995 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754650Ab1FQKSN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 06:18:13 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01265-06 for <netdev@vger.kernel.org>;
 Fri, 17 Jun 2011 11:17:59 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <007701cc2cce$42342320$2804000a@yangyong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> Hello,
> Motioned to the memory aligned, now there is such requirement:
> When the driver send an packet to hardware, the skb's address passed
by
> stack do a dma map into hardware, the skb's dma address must 
> be 64-byte aligned.

Does the hardware support buffer chaining?
In which case you only need to copy the data upto the first
64 byte boundary into another buffer.

Actually, given that you are likely to have to fixup every
fragment of the frame being transmitted, if might be worth
allocating a fixed transmnit buffer area and copying the
frames into it prior to sending.
Certainly you need to allow for transmits made up of a
significant number of small buffers linked together.

Really you should beat up the hardware designers!

Copying the data to even a 4 byte boundary is almost
always a misaligned copy. Typically this only applies
to the receive dma - when writing a 2 byte pad before
the frame data would be much better.

	David


