From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: pmtu discovery on SA
Date: Wed, 18 Jul 2007 14:21:56 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local> <469D3885.7070208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:56194 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758283AbXGRMWE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 08:22:04 -0400
Content-class: urn:content-classes:message
In-reply-to: <469D3885.7070208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > No more crashes with IPComp and smaller PMTUs.
> > But the "pmtu discovery on SA ESP/..." messages don't disappear.
> 
> Thats probably a different issue. Please post the output of
> "ip -x xfrm state" (obfuscate keys if you care ..).

Linux (MTU 1500) <-> ADSL router (1492) <-> ... <-> Linux (1500)

Both boxes show these messages.

src 1.1.1.1 dst 2.2.2.2
        proto comp spi 0x0000e901 reqid 16398 mode tunnel
        replay-window 0
        comp deflate 0x
src 2.2.2.2 dst 1.1.1.1
        proto comp spi 0x000001a3 reqid 16398 mode tunnel
        replay-window 0
        comp deflate 0x
src 1.1.1.1 dst 2.2.2.2
        proto esp spi 0x767eaf0b reqid 16397 mode transport
        replay-window 32
        auth hmac(sha1) 0xxxxxxxxxxxxxxxxxxxxxx
        enc cbc(aes) 0xxxxxxxxxxxxxxxxxxxxxx
src 2.2.2.2 dst 1.1.1.1
        proto esp spi 0x44c5adda reqid 16397 mode transport
        replay-window 32
        auth hmac(sha1) 0xxxxxxxxxxxxxxxxxxxxxx
        enc cbc(aes) 0xxxxxxxxxxxxxxxxxxxxxx
src 2.2.2.2 dst 1.1.1.1
        proto (null) spi 0xd527fed2 reqid 0 mode tunnel
        replay-window 0
src 1.1.1.1 dst 2.2.2.2
        proto (null) spi 0x4cf1a149 reqid 0 mode tunnel
        replay-window 0 
