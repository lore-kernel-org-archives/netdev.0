From: ?? <yangyong@neusoft.com>
Subject: ??: [PATCH] fs_enet: fix freescale FCC ethernet dp buffer alignment
Date: Mon, 20 Jun 2011 12:01:19 +0800
Message-ID: <003801cc2efe$b70571e0$2804000a@yangyong>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8ADA6@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Clive Stubbings' <clive.stubbings@xentech.co.uk>,
	'Vitaly Bordug' <vbordug@ru.mvista.com>
To: 'David Laight' <David.Laight@ACULAB.COM>,
	'Holger Brunck' <holger.brunck@keymile.com>, linuxppc-dev@lists.ozlabs.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-reply-to: <AE90C24D6B3A694183C094C60CF0A2F6D8ADA6@saturn3.aculab.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Hi David Laight, Thank you so much~~
1. Hardware based on FPGA, it dose not support buffer chaining.
2. How dose the dma map support buffer chaining function?
3. On the align issue, the hardware designer start to fix it, maybe it's a
better way.  

-----????-----
???: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] ??
David Laight
????: 2011?6?17? 18:16
???: yangyong@neusoft.com; Holger Brunck; linuxppc-dev@lists.ozlabs.org
??: netdev@vger.kernel.org; Clive Stubbings; Vitaly Bordug
??: RE: [PATCH] fs_enet: fix freescale FCC ethernet dp buffer alignment

 
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


--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

---------------------------------------------------------------------------------------------------
Confidentiality Notice: The information contained in this e-mail and any accompanying attachment(s) 
is intended only for the use of the intended recipient and may be confidential and/or privileged of 
Neusoft Corporation, its subsidiaries and/or its affiliates. If any reader of this communication is 
not the intended recipient, unauthorized use, forwarding, printing,  storing, disclosure or copying 
is strictly prohibited, and may be unlawful.If you have received this communication in error,please 
immediately notify the sender by return e-mail, and delete the original message and all copies from 
your system. Thank you. 
---------------------------------------------------------------------------------------------------
