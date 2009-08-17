From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Mon, 17 Aug 2009 18:17:57 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908171814210.15956@gentwo.org>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org> <ada7hx22j3g.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:56833 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752480AbZHQWSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 18:18:04 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9EF7E82C674
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:18:10 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nG4kPSydNVFl for <netdev@vger.kernel.org>;
	Mon, 17 Aug 2009 18:18:06 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F28D782C66E
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:18:05 -0400 (EDT)
In-Reply-To: <ada7hx22j3g.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009, Roland Dreier wrote:

>
>  > mlx4 fails to initialize here:
>  >
>  >
>  > [    9.973940] mlx4_core 0000:04:00.0: irq 93 for MSI/MSI-X
>  > [    9.983108] sr 1:0:0:0: Attached scsi CD-ROM sr0
>  > [    9.988209] ses 0:0:32:0: Attached scsi generic sg0 type 13
>  > [    9.999376] sd 0:2:0:0: Attached scsi generic sg1 type 0
>  > [   10.010024] sr 1:0:0:0: Attached scsi generic sg2 type 5
>  > [   10.256371] mlx4_core 0000:04:00.0: SW2HW_EQ failed (-5)
>  > [   10.270103] mlx4_core 0000:04:00.0: Failed to initialize event queue
>  > table, aborting.
>  > [   10.288768] mlx4_core 0000:04:00.0: PCI INT A disabled
>  > [   10.299057] mlx4_core: probe of 0000:04:00.0 failed with error -5
>
> Thanks for the report... could you try loading mlx4_core with
> debug_level=1 to see if anything interesting comes out?  The kernel log
> here indicates that the device FW is giving us "internal error" when we
> try to initialize event queues.

Device FW??? The log you wanted follows at the end of this message.

> Also what kernel is this with?  Anything unusual about the system (arch
> != x86, lots of CPUs or RAM, etc)?

Dell R620 two quad nehalems. Build with standard debian kernel config.

> One stab in the dark would be to try a423b8a0 ("mlx4_core: Allocate and
> map sufficient ICM memory for EQ context") from the for-next branch of
> my infiniband.git kernel.org tree.  I would only think that matters if
> you have 32 or more CPUs, but maybe you do...

We have 16 processors.

[ 7423.298136] mlx4_core: Mellanox ConnectX core driver v0.01 (May 1,
2007)
[ 7423.298137] mlx4_core: Initializing 0000:04:00.0
[ 7423.298147] mlx4_core 0000:04:00.0: PCI INT A -> GSI 38 (level, low) ->
IRQ 38
[ 7423.298165] mlx4_core 0000:04:00.0: setting latency timer to 64
[ 7424.298240] mlx4_core 0000:04:00.0: FW version 2.6.000 (cmd intf rev
3), max commands 16
[ 7424.298242] mlx4_core 0000:04:00.0: Catastrophic error buffer at
0x1f020, size 0x10, BAR 0
[ 7424.298243] mlx4_core 0000:04:00.0: FW size 385 KB
[ 7424.298245] mlx4_core 0000:04:00.0: Clear int @ f0058, BAR 0
[ 7424.299848] mlx4_core 0000:04:00.0: Mapped 26 chunks/6168 KB for FW.
[ 7424.921833] mlx4_core 0000:04:00.0: BlueFlame available (reg size 512,
regs/page 256)
[ 7424.921952] mlx4_core 0000:04:00.0: Base MM extensions: flags 00000cc0,
rsvd L_Key 00000500
[ 7424.921954] mlx4_core 0000:04:00.0: Max ICM size 4294967296 MB
[ 7424.921955] mlx4_core 0000:04:00.0: Max QPs: 16777216, reserved QPs:
64, entry size: 256
[ 7424.921957] mlx4_core 0000:04:00.0: Max SRQs: 16777216, reserved SRQs:
64, entry size: 128
[ 7424.921959] mlx4_core 0000:04:00.0: Max CQs: 16777216, reserved CQs:
128, entry size: 128
[ 7424.921960] mlx4_core 0000:04:00.0: Max EQs: 512, reserved EQs: 4,
entry size: 128
[ 7424.921961] mlx4_core 0000:04:00.0: reserved MPTs: 16, reserved MTTs:
16
[ 7424.921963] mlx4_core 0000:04:00.0: Max PDs: 8388608, reserved PDs: 4,
reserved UARs: 1
[ 7424.921964] mlx4_core 0000:04:00.0: Max QP/MCG: 8388608, reserved MGMs:
0
[ 7424.921966] mlx4_core 0000:04:00.0: Max CQEs: 4194304, max WQEs: 16384,
max SRQ WQEs: 16384
[ 7424.921967] mlx4_core 0000:04:00.0: Local CA ACK delay: 15, max MTU:
4096, port width cap: 3
[ 7424.921969] mlx4_core 0000:04:00.0: Max SQ desc size: 1008, max SQ S/G:
62
[ 7424.921970] mlx4_core 0000:04:00.0: Max RQ desc size: 512, max RQ S/G:
32
[ 7424.921971] mlx4_core 0000:04:00.0: Max GSO size: 131072
[ 7424.921972] mlx4_core 0000:04:00.0: DEV_CAP flags:
[ 7424.921974] mlx4_core 0000:04:00.0:     RC transport
[ 7424.921975] mlx4_core 0000:04:00.0:     UC transport
[ 7424.921976] mlx4_core 0000:04:00.0:     UD transport
[ 7424.921977] mlx4_core 0000:04:00.0:     XRC transport
[ 7424.921978] mlx4_core 0000:04:00.0:     FCoIB support
[ 7424.921979] mlx4_core 0000:04:00.0:     SRQ support
[ 7424.921980] mlx4_core 0000:04:00.0:     IPoIB checksum offload
[ 7424.921981] mlx4_core 0000:04:00.0:     P_Key violation counter
[ 7424.921982] mlx4_core 0000:04:00.0:     Q_Key violation counter
[ 7424.921983] mlx4_core 0000:04:00.0:     DPDP
[ 7424.921984] mlx4_core 0000:04:00.0:     APM support
[ 7424.921985] mlx4_core 0000:04:00.0:     Atomic ops support
[ 7424.921986] mlx4_core 0000:04:00.0:     Address vector port checking
support
[ 7424.921988] mlx4_core 0000:04:00.0:     UD multicast support
[ 7424.921989] mlx4_core 0000:04:00.0:     Router support
[ 7424.921993] mlx4_core 0000:04:00.0:   profile[ 0] (  CMPT): 2^26
entries @ 0x         0, size 0x 100000000
[ 7424.921995] mlx4_core 0000:04:00.0:   profile[ 1] (RDMARC): 2^21
entries @ 0x 100000000, size 0x   4000000
[ 7424.921997] mlx4_core 0000:04:00.0:   profile[ 2] (   MTT): 2^20
entries @ 0x 104000000, size 0x   4000000
[ 7424.921999] mlx4_core 0000:04:00.0:   profile[ 3] (    QP): 2^17
entries @ 0x 108000000, size 0x   2000000
[ 7424.922001] mlx4_core 0000:04:00.0:   profile[ 4] (  ALTC): 2^17
entries @ 0x 10a000000, size 0x    800000
[ 7424.922003] mlx4_core 0000:04:00.0:   profile[ 5] (   SRQ): 2^16
entries @ 0x 10a800000, size 0x    800000
[ 7424.922005] mlx4_core 0000:04:00.0:   profile[ 6] (    CQ): 2^16
entries @ 0x 10b000000, size 0x    800000
[ 7424.922007] mlx4_core 0000:04:00.0:   profile[ 7] (  DMPT): 2^17
entries @ 0x 10b800000, size 0x    800000
[ 7424.922009] mlx4_core 0000:04:00.0:   profile[ 8] (   MCG): 2^13
entries @ 0x 10c000000, size 0x    200000
[ 7424.922011] mlx4_core 0000:04:00.0:   profile[ 9] (  AUXC): 2^17
entries @ 0x 10c200000, size 0x     20000
[ 7424.922013] mlx4_core 0000:04:00.0:   profile[10] (    EQ): 2^06
entries @ 0x 10c220000, size 0x      2000
[ 7424.922014] mlx4_core 0000:04:00.0: HCA context memory: reserving
4393096 KB
[ 7424.922034] mlx4_core 0000:04:00.0: 4393096 KB of HCA context requires
8620 KB aux memory.
[ 7424.942888] mlx4_core 0000:04:00.0: Mapped 37 chunks/8620 KB for ICM
aux.
[ 7424.943998] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 0 for
ICM.
[ 7424.945080] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 40000000
for ICM.
[ 7424.946162] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 80000000
for ICM.
[ 7424.946192] mlx4_core 0000:04:00.0: Mapped 1 chunks/4 KB at c0000000
for ICM.
[ 7424.946221] mlx4_core 0000:04:00.0: Mapped page at 1a79c4000 to
10c220000 for ICM.
[ 7424.947283] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 104000000
for ICM.
[ 7424.948380] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10b800000
for ICM.
[ 7424.949441] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 108000000
for ICM.
[ 7424.949976] mlx4_core 0000:04:00.0: Mapped 1 chunks/128 KB at 10c200000
for ICM.
[ 7424.951037] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10a000000
for ICM.
[ 7424.952098] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 100000000
for ICM.
[ 7424.953159] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10b000000
for ICM.
[ 7424.954219] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10a800000
for ICM.
[ 7424.955279] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10c000000
for ICM.
[ 7424.956339] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10c040000
for ICM.
[ 7424.957399] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10c080000
for ICM.
[ 7424.958458] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10c0c0000
for ICM.
[ 7424.959519] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10c100000
for ICM.
[ 7424.960581] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10c140000
for ICM.
[ 7424.961641] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10c180000
for ICM.
[ 7424.962702] mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 10c1c0000
for ICM.
[ 7425.199430] mlx4_core 0000:04:00.0: irq 70 for MSI/MSI-X
[ 7425.199432] mlx4_core 0000:04:00.0: irq 71 for MSI/MSI-X
[ 7425.199434] mlx4_core 0000:04:00.0: irq 72 for MSI/MSI-X
[ 7425.199436] mlx4_core 0000:04:00.0: irq 73 for MSI/MSI-X
[ 7425.199437] mlx4_core 0000:04:00.0: irq 74 for MSI/MSI-X
[ 7425.199439] mlx4_core 0000:04:00.0: irq 75 for MSI/MSI-X
[ 7425.199441] mlx4_core 0000:04:00.0: irq 76 for MSI/MSI-X
[ 7425.199443] mlx4_core 0000:04:00.0: irq 77 for MSI/MSI-X
[ 7425.199445] mlx4_core 0000:04:00.0: irq 78 for MSI/MSI-X
[ 7425.199446] mlx4_core 0000:04:00.0: irq 79 for MSI/MSI-X
[ 7425.199448] mlx4_core 0000:04:00.0: irq 80 for MSI/MSI-X
[ 7425.199450] mlx4_core 0000:04:00.0: irq 81 for MSI/MSI-X
[ 7425.199452] mlx4_core 0000:04:00.0: irq 82 for MSI/MSI-X
[ 7425.199454] mlx4_core 0000:04:00.0: irq 83 for MSI/MSI-X
[ 7425.199456] mlx4_core 0000:04:00.0: irq 84 for MSI/MSI-X
[ 7425.199457] mlx4_core 0000:04:00.0: irq 85 for MSI/MSI-X
[ 7425.199459] mlx4_core 0000:04:00.0: irq 86 for MSI/MSI-X
[ 7425.199461] mlx4_core 0000:04:00.0: irq 87 for MSI/MSI-X
[ 7425.199463] mlx4_core 0000:04:00.0: irq 88 for MSI/MSI-X
[ 7425.199464] mlx4_core 0000:04:00.0: irq 89 for MSI/MSI-X
[ 7425.199466] mlx4_core 0000:04:00.0: irq 90 for MSI/MSI-X
[ 7425.199468] mlx4_core 0000:04:00.0: irq 91 for MSI/MSI-X
[ 7425.199470] mlx4_core 0000:04:00.0: irq 92 for MSI/MSI-X
[ 7425.199472] mlx4_core 0000:04:00.0: irq 93 for MSI/MSI-X
[ 7425.199474] mlx4_core 0000:04:00.0: irq 94 for MSI/MSI-X
[ 7425.199475] mlx4_core 0000:04:00.0: irq 95 for MSI/MSI-X
[ 7425.199477] mlx4_core 0000:04:00.0: irq 96 for MSI/MSI-X
[ 7425.199479] mlx4_core 0000:04:00.0: irq 97 for MSI/MSI-X
[ 7425.199481] mlx4_core 0000:04:00.0: irq 98 for MSI/MSI-X
[ 7425.199483] mlx4_core 0000:04:00.0: irq 99 for MSI/MSI-X
[ 7425.199485] mlx4_core 0000:04:00.0: irq 100 for MSI/MSI-X
[ 7425.199487] mlx4_core 0000:04:00.0: irq 101 for MSI/MSI-X
[ 7425.199488] mlx4_core 0000:04:00.0: irq 102 for MSI/MSI-X
[ 7425.472921] mlx4_core 0000:04:00.0: SW2HW_EQ failed (-5)
[ 7425.476030] mlx4_core 0000:04:00.0: Failed to initialize event queue
table, aborting.
[ 7425.494648] mlx4_core 0000:04:00.0: PCI INT A disabled
[ 7425.494660] mlx4_core: probe of 0000:04:00.0 failed with error -5

