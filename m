From: Michael-Luke Jones <mlj28@cam.ac.uk>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 8 May 2007 09:35:54 +0100
Message-ID: <94A84191-A7C6-41D2-83A0-2C28EB210B5B@cam.ac.uk>
References: <200705080826.l488Qnrb006666@harpo.it.uu.se>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Jeff Garzik <jeff@garzik.org>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Russell King <rmk@arm.linux.org.uk>
To: Mikael Pettersson <mikpe@it.uu.se>,
	Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppsw-2.csi.cam.ac.uk ([131.111.8.132]:32838 "EHLO
	ppsw-2.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934678AbXEHIgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 04:36:53 -0400
In-Reply-To: <200705080826.l488Qnrb006666@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8 May 2007, at 09:26, Mikael Pettersson wrote:

> On Tue, 8 May 2007 08:22:17 +0100, Michael-Luke Jones wrote:
> AFAIK, it's a HW limitation of the IXP4xx NPEs, or
> possibly Intel's microcode for them.
>
> I run my IXP42x boxes big-endian and don't mind doing so.
>
> /Mikael

*cough*
http://www.hohnstaedt.de/ixp_npe/0.2.0/0001-IXP4XX-Driver-for-NPE- 
QMGR-MAC-0.2.0.txt
:p

---

On 8 May 2007, at 09:29, Tomasz Chmielewski wrote:
> Christian Hohnstaedt's work did support LE though.

Indeed.

> Krzysztof, why is LE not supported?

Butting in here. It's not supported because LE mode has to work in a  
brain-damaged way. NPE DMAs the complete skb straight out of RAM.  
Unfortunately it expects the skb to already be written out in ram BE.

Thus, in LE mode we have to byteswap the skb with CPU before the NPE  
can DMA it. This hasn't been implemented yet.

Michael-Luke Jones

