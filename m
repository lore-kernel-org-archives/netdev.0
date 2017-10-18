From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Problems with mvneta
Date: Wed, 18 Oct 2017 22:55:57 +0200
Message-ID: <20171018225557.43837338@windsurf.home>
References: <20171018223425.42ce7a74@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: =?UTF-8?B?R3LDqWdvcnk=?= Clement
        <gregory.clement@free-electrons.com>,
        Antoine =?UTF-8?B?VMOpbmFydA==?=
        <antoine.tenart@free-electrons.com>, netdev@vger.kernel.org,
        Marcin Wojtas <mw@semihalf.com>
To: Sven =?UTF-8?B?TcO8bGxlcg==?= <musv@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34054 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751701AbdJRU4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 16:56:08 -0400
In-Reply-To: <20171018223425.42ce7a74@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm adding my colleagues Grégory Clement and Antoine Ténart in Cc, as
well as Marcin Wojtas, who also worked on mvneta, and the netdev
mailing list. I'm keeping your full message below so that others can
read the context.

On Wed, 18 Oct 2017 22:34:25 +0200, Sven Müller wrote:

> I've found your email address in the kernel sources of the mvneta driver. I didn't find a bug system on free-electrons.com. And on kernel.org searching for mvneta wasn't really helpful. 

There is a bug tracker for the Linux kernel at
https://bugzilla.kernel.org/. However, I indeed wouldn't be notified of
bug reports against mvneta.

> Some people including me hacked the Zyxel NSA-326 some time ago. The whole thread you can find here: 
> 
> https://forum.doozan.com/read.php?2,27108
> 
> Until kernel 4.10.10 everything worked great. I didn't test 4.11. But any higher kernel version (tested 4.12., 4.13) causes network problems with nfs. I described it here:
> 
> https://forum.doozan.com/read.php?2,27108,37699#msg-37699
> 
> Transfering files not with full speed but over a longer period of time, e.g. playing music files over nfs or reading a lot of smaller files causes the error: 
> 
> Sep 27 17:35:37 nas kernel: rpc-srv/tcp: nfsd: sent only 36488 when sending 65644 bytes - shutting down socket
> 
> After that message the network is down. I have to reboot the device in order to get any network connectivity again. And how I wrote: 4.10.10 works perfectly. 4.12 produced a lot of this errors, 4.13 seems to be a little bit better. 
> 
> Unfortunately I didn't find a way to reproduce this problem directly. It occurs after 5 minutes up to one hour of transferring files via nfs. 
> 
> If you are interested in fixing this bug, I would like to support you with providing you any information I can find on my system and testing. 
> 
> My kernel config, which is working in 4.10.10 and producing the nfs problem in 4.12 and 4.13: 
> 
> https://paste.pound-python.org/show/RCaG9J4yBy79K3NL5F1
> 
> and the device tree: 
> 
> https://paste.pound-python.org/show/UiLpMgUERuCddHOn6Vsp/

There have been a few changes in the mvneta code between 4.10 and 4.12,
but not many of them look potentially problematic.

f95936cca6a8410ebdaf164bc5d3ade9e1de5bdb net: mvneta: Adjust six checks for null pointers
d441b688a1bce8e2e1b43d8090738c306dd09131 net: mvneta: Use kmalloc_array() in mvneta_txq_init()
5d6312ed57a909c86bb9472b2bbc012539392e7d net: mvneta: Improve two size determinations in mvneta_init()
2911063011fc7adcb43c93e9c3e9dc7798f459f5 net: mvneta: Use devm_kmalloc_array() in mvneta_init()
82960fff09bc394e2a33d5369969410699c04861 net: mvneta: fix failed to suspend if WOL is enabled
d6956ac87b5ff6841b09c273a70de86200d82019 net: mvneta: set rx mode during resume if interface is running
a38d20d791fdcd79ebccda15a8308a6d8ada6e1c net: mvneta: add RGMII_RXID and RGMII_TXID support
9768b45ceb0bc7bdee61837afad331dd6bf7977f net: mvneta: support suspend and resume
4581be42fce5e1d208cbeb8e78df3f1b4673eff7 net: mvneta: make mvneta_eth_tool_ops static
9303ab2b3402b60f6c39abfdbfa4ce00fce8bee4 net: mvneta: fix build errors when linux/phy*.h is removed from net/dsa.h
b60a00f9c5f14695991cb77dce7e926623269d88 net: mvneta: implement .set_wol and .get_wol
6ad20165d376fa07919a70e4f43dfae564601829 drivers: net: generalize napi_complete_done()
a29b6235560a1ed10c8e1a73bfc616a66b802b90 net: mvneta: add BQL support
2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a net: mvneta: add xmit_more support
bc1f44709cf27fb2a5766cadafe7e2ad5e9cb221 net: make ndo_get_stats64 a void function

The only ones that really could have an impact are:

6ad20165d376fa07919a70e4f43dfae564601829 drivers: net: generalize napi_complete_done()
a29b6235560a1ed10c8e1a73bfc616a66b802b90 net: mvneta: add BQL support
2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a net: mvneta: add xmit_more support

Could you try to take mvneta* from Linux 4.10, put that in Linux 4.12,
and see if you can still produce the problem? I'd like to first make
sure the problem really is inside mvneta, and not in some other place.

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
