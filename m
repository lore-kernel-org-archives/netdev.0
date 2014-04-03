From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 3 Apr 2014 15:42:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6EF663@AcuExch.aculab.com>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org>
 <1396358832-15828-4-git-send-email-zhangfei.gao@linaro.org>
 <9532591.5yuCbpL4pV@wuerfel> <20140403152746.GQ7528@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39703 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752665AbaDCPnW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 11:43:22 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07418-03 for <netdev@vger.kernel.org>;
 Thu,  3 Apr 2014 16:43:18 +0100 (BST)
In-Reply-To: <20140403152746.GQ7528@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux
> DMA coherent memory is write combining, so multiple writes will be
> coalesced.  This also means that barriers may be required to ensure the
> descriptors are pushed out in a timely manner if something like writel()
> is not used in the transmit-triggering path.

You also have to ensure that the write that changes the 'owner'
bit is the one that happens last.

If (for example) a descriptor has two words, one containing the
buffer address and the other containing the length and flags,
then you have to absolutely ensure that the hardware will not
read the new 'flags' with the old 'buffer address'.
Any write to tell the hardware to look at the tx ring won't
help you - the hardware might be reading the descriptor anyway.

Even if the accesses are uncached, you need the appropriate
barrier (or volatiles) to stop gcc reordering the writes.
(I think accesses to volatiles can't be reordered - check.)

	David
