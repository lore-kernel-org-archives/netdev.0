From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: Face some error after applying commit 7dfa4b414d4(net/mlx4_en:
 Code cleanups in tx path)
Date: Tue, 11 Nov 2014 17:12:51 +0800
Message-ID: <20141111091251.GA5858@richard>
References: <20141108025758.GA13875@richard>
 <CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com>
 <20141110015933.GB6294@richard>
 <1415587574.13896.131.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141110054010.GA3224@richard>
 <54607095.6070302@mellanox.com>
 <20141111015705.GA8470@richard>
 <CAPcc5Ph-guxyUj96VQa1FqTsnwU3J8em4wv0E+ddYho71o0v4w@mail.gmail.com>
 <20141111074243.GA25321@richard>
 <CAPcc5PgFqzSVZ9rj8yj7LyuCjQXafP5J4bohcL4h7SFMc-rAJg@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, gerlitz.or@gmail.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:48764 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbaKKJNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 04:13:01 -0500
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 11 Nov 2014 19:12:58 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 0E3553578074
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 20:12:55 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAB9EoFK32178342
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 20:14:51 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAB9CrPk012041
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 20:12:53 +1100
Content-Disposition: inline
In-Reply-To: <CAPcc5PgFqzSVZ9rj8yj7LyuCjQXafP5J4bohcL4h7SFMc-rAJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 10:40:24AM +0200, Amir Vadai wrote:
>On Tue, Nov 11, 2014 at 9:42 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>>>>Hi,
>>>>>
>>>>>Lets see that we're on the same page here:
>>>>>1. There was a compilation problem that you fixed (Yes, it was my fault
>>>>>- I just discovered it a minute after the code was applied).
>>>>>2. When you're using SR-IOV, during initialization, you get a CQE error
>>>>>with syndrome 0x2 on one of the probed VF's.
>>>>
>>>> From the log, seems yes.
>>>>
>>>>>3. Regarding the BlueFlame - I don't see how it is related to the issue
>>>>>that you see. But it is a very easy experiment. Issue: "ethtool
>>>>>--set-priv-flags eth1 blueflame off"
>>>>
>>>> I tried to use this after mlx4_en is loaded, still see the CQE error.
>>>>
>>>>>
>>>>>Please send me the module parameters you used when loading mlx4_core, a
>>>>>full dmesg with both mlx4_core and mlx4_en loading.
>>>>
>>>> The command line I use is:
>>>>         modprobe mlx4_core num_vfs=1 probe_vf=1 port_type_array=2,2
>>>>
>>>> The log I sent in the first mail is the full log, including the CQE error, one
>>>> warning in watchdog, and then print the CQE error periodicly. What else
>>>> message you would like me to capture?
>>>
>>>The log in the first mail has only mlx4_en logs. I would like to see
>>>the full log, that has mlx4_core messages too. And as Or suggested,
>>>debug_level=1 could be useful here too.
>>>
>>
>> Ah, you need the log from mlx4_core too. Ok, I will do it again.
>>
>> BTW, how to add the debug_level=1 in the command line? Like this?
>>
>> modprobe mlx4_core num_vfs=1 probe_vf=1 port_type_array=2,2 debug_level=1
>yes
>

I past the full log here, but I don't see the log level affact.


[ 5723.612882] mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
[ 5723.612979] mlx4_core: Initializing 0003:05:00.0
[ 5723.613023] pci 0003:05: 0.1: [PE# 222] VF 0003:05:00.1 associated with PE#222
[ 5723.613299] pci 0003:05: 0.1: [PE# 222] Setting up 32-bit TCE table at 0..80000000
[ 5723.684140] pci 0003:05: 0.1: [PE# 222] Enabling 64-bit DMA bypass
[ 5723.684215] pci 0003:05: 0.2: [PE# 223] VF 0003:05:00.2 associated with PE#223
[ 5723.684409] pci 0003:05: 0.2: [PE# 223] Setting up 32-bit TCE table at 0..80000000
[ 5723.754871] pci 0003:05: 0.2: [PE# 223] Enabling 64-bit DMA bypass
[ 5723.754944] pci 0003:05: 0.3: [PE# 224] VF 0003:05:00.3 associated with PE#224
[ 5723.755150] pci 0003:05: 0.3: [PE# 224] Setting up 32-bit TCE table at 0..80000000
[ 5723.825646] pci 0003:05: 0.3: [PE# 224] Enabling 64-bit DMA bypass
[ 5723.825718] pci 0003:05: 0.4: [PE# 225] VF 0003:05:00.4 associated with PE#225
[ 5723.825911] pci 0003:05: 0.4: [PE# 225] Setting up 32-bit TCE table at 0..80000000
[ 5723.896342] pci 0003:05: 0.4: [PE# 225] Enabling 64-bit DMA bypass
[ 5723.896416] pci 0003:05: 0.5: [PE# 226] VF 0003:05:00.5 associated with PE#226
[ 5723.896610] pci 0003:05: 0.5: [PE# 226] Setting up 32-bit TCE table at 0..80000000
[ 5723.967052] pci 0003:05: 0.5: [PE# 226] Enabling 64-bit DMA bypass
[ 5723.967135] pci 0003:05: 0.6: [PE# 227] VF 0003:05:00.6 associated with PE#227
[ 5723.967328] pci 0003:05: 0.6: [PE# 227] Setting up 32-bit TCE table at 0..80000000
[ 5724.037755] pci 0003:05: 0.6: [PE# 227] Enabling 64-bit DMA bypass
[ 5724.037829] pci 0003:05: 0.7: [PE# 228] VF 0003:05:00.7 associated with PE#228
[ 5724.038022] pci 0003:05: 0.7: [PE# 228] Setting up 32-bit TCE table at 0..80000000
[ 5724.108452] pci 0003:05: 0.7: [PE# 228] Enabling 64-bit DMA bypass
[ 5724.108525] pci 0003:05: 1.0: [PE# 229] VF 0003:05:01.0 associated with PE#229
[ 5724.108718] pci 0003:05: 1.0: [PE# 229] Setting up 32-bit TCE table at 0..80000000
[ 5724.179209] pci 0003:05: 1.0: [PE# 229] Enabling 64-bit DMA bypass
[ 5724.179293] pci 0003:05: 1.1: [PE# 230] VF 0003:05:01.1 associated with PE#230
[ 5724.179486] pci 0003:05: 1.1: [PE# 230] Setting up 32-bit TCE table at 0..80000000
[ 5724.249946] pci 0003:05: 1.1: [PE# 230] Enabling 64-bit DMA bypass
[ 5724.250020] pci 0003:05: 1.2: [PE# 231] VF 0003:05:01.2 associated with PE#231
[ 5724.250214] pci 0003:05: 1.2: [PE# 231] Setting up 32-bit TCE table at 0..80000000
[ 5724.320703] pci 0003:05: 1.2: [PE# 231] Enabling 64-bit DMA bypass
[ 5724.320787] pci 0003:05: 1.3: [PE# 232] VF 0003:05:01.3 associated with PE#232
[ 5724.320982] pci 0003:05: 1.3: [PE# 232] Setting up 32-bit TCE table at 0..80000000
[ 5724.391424] pci 0003:05: 1.3: [PE# 232] Enabling 64-bit DMA bypass
[ 5724.391497] pci 0003:05: 1.4: [PE# 233] VF 0003:05:01.4 associated with PE#233
[ 5724.391690] pci 0003:05: 1.4: [PE# 233] Setting up 32-bit TCE table at 0..80000000
[ 5724.462129] pci 0003:05: 1.4: [PE# 233] Enabling 64-bit DMA bypass
[ 5724.462215] pci 0003:05: 1.5: [PE# 234] VF 0003:05:01.5 associated with PE#234
[ 5724.462408] pci 0003:05: 1.5: [PE# 234] Setting up 32-bit TCE table at 0..80000000
[ 5724.532834] pci 0003:05: 1.5: [PE# 234] Enabling 64-bit DMA bypass
[ 5724.532907] pci 0003:05: 1.6: [PE# 235] VF 0003:05:01.6 associated with PE#235
[ 5724.533100] pci 0003:05: 1.6: [PE# 235] Setting up 32-bit TCE table at 0..80000000
[ 5724.603556] pci 0003:05: 1.6: [PE# 235] Enabling 64-bit DMA bypass
[ 5724.603628] pci 0003:05: 1.7: [PE# 236] VF 0003:05:01.7 associated with PE#236
[ 5724.603822] pci 0003:05: 1.7: [PE# 236] Setting up 32-bit TCE table at 0..80000000
[ 5724.674261] pci 0003:05: 1.7: [PE# 236] Enabling 64-bit DMA bypass
[ 5724.674334] pci 0003:05: 2.0: [PE# 237] VF 0003:05:02.0 associated with PE#237
[ 5724.674528] pci 0003:05: 2.0: [PE# 237] Setting up 32-bit TCE table at 0..80000000
[ 5724.745012] pci 0003:05: 2.0: [PE# 237] Enabling 64-bit DMA bypass
[ 5724.745088] pci 0003:05: 2.1: [PE# 238] VF 0003:05:02.1 associated with PE#238
[ 5724.745281] pci 0003:05: 2.1: [PE# 238] Setting up 32-bit TCE table at 0..80000000
[ 5724.815714] pci 0003:05: 2.1: [PE# 238] Enabling 64-bit DMA bypass
[ 5724.815786] pci 0003:05: 2.2: [PE# 239] VF 0003:05:02.2 associated with PE#239
[ 5724.815979] pci 0003:05: 2.2: [PE# 239] Setting up 32-bit TCE table at 0..80000000
[ 5724.886413] pci 0003:05: 2.2: [PE# 239] Enabling 64-bit DMA bypass
[ 5724.886487] pci 0003:05: 2.3: [PE# 240] VF 0003:05:02.3 associated with PE#240
[ 5724.886680] pci 0003:05: 2.3: [PE# 240] Setting up 32-bit TCE table at 0..80000000
[ 5724.957126] pci 0003:05: 2.3: [PE# 240] Enabling 64-bit DMA bypass
[ 5724.957210] pci 0003:05: 2.4: [PE# 241] VF 0003:05:02.4 associated with PE#241
[ 5724.957403] pci 0003:05: 2.4: [PE# 241] Setting up 32-bit TCE table at 0..80000000
[ 5725.027842] pci 0003:05: 2.4: [PE# 241] Enabling 64-bit DMA bypass
[ 5725.027917] pci 0003:05: 2.5: [PE# 242] VF 0003:05:02.5 associated with PE#242
[ 5725.028109] pci 0003:05: 2.5: [PE# 242] Setting up 32-bit TCE table at 0..80000000
[ 5725.098551] pci 0003:05: 2.5: [PE# 242] Enabling 64-bit DMA bypass
[ 5725.098624] pci 0003:05: 2.6: [PE# 243] VF 0003:05:02.6 associated with PE#243
[ 5725.098818] pci 0003:05: 2.6: [PE# 243] Setting up 32-bit TCE table at 0..80000000
[ 5725.169255] pci 0003:05: 2.6: [PE# 243] Enabling 64-bit DMA bypass
[ 5725.169338] pci 0003:05: 2.7: [PE# 244] VF 0003:05:02.7 associated with PE#244
[ 5725.169532] pci 0003:05: 2.7: [PE# 244] Setting up 32-bit TCE table at 0..80000000
[ 5725.239962] pci 0003:05: 2.7: [PE# 244] Enabling 64-bit DMA bypass
[ 5725.240036] pci 0003:05: 3.0: [PE# 245] VF 0003:05:03.0 associated with PE#245
[ 5725.240229] pci 0003:05: 3.0: [PE# 245] Setting up 32-bit TCE table at 0..80000000
[ 5725.310678] pci 0003:05: 3.0: [PE# 245] Enabling 64-bit DMA bypass
[ 5725.310751] pci 0003:05: 3.1: [PE# 246] VF 0003:05:03.1 associated with PE#246
[ 5725.310944] pci 0003:05: 3.1: [PE# 246] Setting up 32-bit TCE table at 0..80000000
[ 5725.381375] pci 0003:05: 3.1: [PE# 246] Enabling 64-bit DMA bypass
[ 5725.381459] pci 0003:05: 3.2: [PE# 247] VF 0003:05:03.2 associated with PE#247
[ 5725.381653] pci 0003:05: 3.2: [PE# 247] Setting up 32-bit TCE table at 0..80000000
[ 5725.452087] pci 0003:05: 3.2: [PE# 247] Enabling 64-bit DMA bypass
[ 5725.452171] pci 0003:05: 3.3: [PE# 248] VF 0003:05:03.3 associated with PE#248
[ 5725.452365] pci 0003:05: 3.3: [PE# 248] Setting up 32-bit TCE table at 0..80000000
[ 5725.522815] pci 0003:05: 3.3: [PE# 248] Enabling 64-bit DMA bypass
[ 5725.522889] pci 0003:05: 3.4: [PE# 249] VF 0003:05:03.4 associated with PE#249
[ 5725.523082] pci 0003:05: 3.4: [PE# 249] Setting up 32-bit TCE table at 0..80000000
[ 5725.593516] pci 0003:05: 3.4: [PE# 249] Enabling 64-bit DMA bypass
[ 5725.593590] pci 0003:05: 3.5: [PE# 250] VF 0003:05:03.5 associated with PE#250
[ 5725.593783] pci 0003:05: 3.5: [PE# 250] Setting up 32-bit TCE table at 0..80000000
[ 5725.664330] pci 0003:05: 3.5: [PE# 250] Enabling 64-bit DMA bypass
[ 5725.664403] pci 0003:05: 3.6: [PE# 251] VF 0003:05:03.6 associated with PE#251
[ 5725.664597] pci 0003:05: 3.6: [PE# 251] Setting up 32-bit TCE table at 0..80000000
[ 5725.735081] pci 0003:05: 3.6: [PE# 251] Enabling 64-bit DMA bypass
[ 5725.735154] pci 0003:05: 3.7: [PE# 252] VF 0003:05:03.7 associated with PE#252
[ 5725.735348] pci 0003:05: 3.7: [PE# 252] Setting up 32-bit TCE table at 0..80000000
[ 5725.805792] pci 0003:05: 3.7: [PE# 252] Enabling 64-bit DMA bypass
[ 5725.805865] pci 0003:05: 4.0: [PE# 253] VF 0003:05:04.0 associated with PE#253
[ 5725.806058] pci 0003:05: 4.0: [PE# 253] Setting up 32-bit TCE table at 0..80000000
[ 5725.876496] pci 0003:05: 4.0: [PE# 253] Enabling 64-bit DMA bypass
[ 5725.876570] pci 0003:05: 4.1: [PE# 254] VF 0003:05:04.1 associated with PE#254
[ 5725.876763] pci 0003:05: 4.1: [PE# 254] Setting up 32-bit TCE table at 0..80000000
[ 5725.945133] pci 0003:05: 4.1: [PE# 254] Enabling 64-bit DMA bypass
[ 5725.945212] pci 0003:05: 4.2: [PE# 255] VF 0003:05:04.2 associated with PE#255
[ 5725.945316] pci 0003:05: 4.2: [PE# 255] Setting up 32-bit TCE table at 0..80000000
[ 5726.006975] pci 0003:05: 4.2: [PE# 255] Enabling 64-bit DMA bypass
[ 5726.007163] mlx4_core 0003:05:00.0: Using 64-bit DMA iommu bypass
[ 5726.007227] mlx4_core 0003:05:00.0: Enabling SR-IOV with 1 VFs
[ 5726.116742] mlx4_core: Initializing 0003:05:00.1
[ 5726.116825] mlx4_core 0003:05:00.1: enabling device (0000 -> 0002)
[ 5726.116914] mlx4_core 0003:05:00.1: Using 64-bit DMA iommu bypass
[ 5726.116976] mlx4_core 0003:05:00.1: Detected virtual function - running in slave mode
[ 5726.117191] mlx4_core 0003:05:00.1: PF is not ready - Deferring probe
[ 5726.117276] pci 0003:05:00.1: Driver mlx4_core requests probe deferral
[ 5726.117363] mlx4_core 0003:05:00.0: Running in master mode
[ 5731.123148] mlx4_core 0003:05:00.0: PCIe link speed is 8.0GT/s, device supports 8.0GT/s
[ 5731.123227] mlx4_core 0003:05:00.0: PCIe link width is x8, device supports x8
[ 5731.151307] mlx4_core: Initializing 0003:05:00.1
[ 5731.151389] mlx4_core 0003:05:00.1: enabling device (0000 -> 0002)
[ 5731.151501] mlx4_core 0003:05:00.1: Using 64-bit DMA iommu bypass
[ 5731.151559] mlx4_core 0003:05:00.1: Detected virtual function - running in slave mode
[ 5731.151636] mlx4_core 0003:05:00.1: Sending reset
[ 5731.151770] mlx4_core 0003:05:00.0: Received reset from slave:1
[ 5731.152189] mlx4_core 0003:05:00.1: Sending vhcr0
[ 5731.152991] mlx4_core 0003:05:00.1: HCA minimum page size:512
[ 5731.153444] mlx4_core 0003:05:00.1: Timestamping is not supported in slave mode
[root@tian-lp1 ywywyang]# [ 5731.229958] mlx4_en: Mellanox ConnectX HCA Ethernet driver v2.2-1 (Feb 2014)
[ 5731.230572] mlx4_en 0003:05:00.0: registered PHC clock
[ 5731.230817] mlx4_en 0003:05:00.0: Activating port:1
[ 5731.262377] mlx4_en: eth12: Using 256 TX rings
[ 5731.262494] mlx4_en: eth12: Using 4 RX rings
[ 5731.262546] mlx4_en: eth12:   frag:0 - size:1518 prefix:0 align:0 stride:1536
[ 5731.262761] mlx4_en: eth12: Initializing port
[ 5731.263357] mlx4_en 0003:05:00.1: Activating port:1
[ 5731.263467] mlx4_en: 0003:05:00.1: Port 1: Assigned random MAC address d6:0f:0b:57:36:24
[ 5731.442926] mlx4_en: eth13: Using 256 TX rings
[ 5731.443010] mlx4_en: eth13: Using 4 RX rings
[ 5731.443018] mlx4_en: eth13:   frag:0 - size:1518 prefix:0 align:0 stride:1536
[ 5731.443304] mlx4_en: eth13: Initializing port
[ 5732.096548] mlx4_en: eth13:   frag:0 - size:1518 prefix:0 align:0 stride:1536
[ 5732.452283] IPv6: ADDRCONF(NETDEV_UP): eth13: link is not ready
[ 5732.951420] mlx4_en: eth12: Link Up
[ 5732.951477] mlx4_en: eth13: Link Up
[ 5732.951627] IPv6: ADDRCONF(NETDEV_CHANGE): eth13: link becomes ready
[ 5733.171020] mlx4_en: eth13: CQE error - vendor syndrome: 0x6f syndrome: 0x2
[ 5733.315756] mlx4_en: eth13: CQE error - vendor syndrome: 0x6f syndrome: 0x2
[ 5734.165387] mlx4_en: eth13: CQE error - vendor syndrome: 0x6f syndrome: 0x2
[ 5748.045084] NETDEV WATCHDOG: eth13 (mlx4_core): transmit queue 1 timed out
[ 5748.045245] ------------[ cut here ]------------
[ 5748.045301] WARNING: at net/sched/sch_generic.c:303
[ 5748.045355] Modules linked in: mlx4_en(O) mlx4_core nf_conntrack_ipv6 nf_defrag_ipv6 bnep nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack bluetooth rfkill ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_security iptable_raw be2net tg3 ptp pps_core nfsd nfs_acl ses enclosure kvm_hv kvm_pr kvm lockd grace binfmt_misc shpchp sunrpc uinput lpfc ipr scsi_transport_fc [last unloaded: mlx4_core]
[ 5748.046069] CPU: 1 PID: 0 Comm: swapper/1 Tainted: P           O   3.18.0-rc2yw+ #161
[ 5748.046142] task: c0000027ef4f92d0 ti: c0000027ef574000 task.ti: c0000027ef574000
[ 5748.046215] NIP: c00000000079a9d4 LR: c00000000079a9d0 CTR: 0000000030044878
[ 5748.046286] REGS: c0000027ef5772d0 TRAP: 0700   Tainted: P           O    (3.18.0-rc2yw+)
[ 5748.046357] MSR: 9000000000029032 <SF,HV,EE,ME,IR,DR,RI>  CR: 28004024  XER: 00000000
[ 5748.046524] CFAR: c0000000008be150 SOFTE: 1 
GPR00: c00000000079a9d0 c0000027ef577550 c00000000147acf0 000000000000003e 
GPR04: c000002004145888 c000002004156240 9000000000009032 0000000000000029 
GPR08: c000000000d1acf0 0000000000000000 0000002003430000 0000000030044954 
GPR12: 0000000028004022 c00000000fdc0900 0000000000000001 c0000000008f10a8 
GPR16: c0000027ef795438 c0000027ef795838 c0000027ef795c38 0000000000000000 
GPR20: c0000027ef795038 c0000000014b2200 0000000000000000 0000000000000000 
GPR24: 0000000000000000 ffffffffffffffff 0000000000000000 0000000000000001 
GPR28: 0000000000000004 c0000000014b2200 c000002781340000 0000000000000001 
[ 5748.047435] NIP [c00000000079a9d4] .dev_watchdog+0x354/0x370
[ 5748.047496] LR [c00000000079a9d0] .dev_watchdog+0x350/0x370
[ 5748.047544] Call Trace:
[ 5748.047570] [c0000027ef577550] [c00000000079a9d0] .dev_watchdog+0x350/0x370 (unreliable)
[ 5748.047655] [c0000027ef577600] [c0000000001275a4] .call_timer_fn+0x64/0x190
[ 5748.047727] [c0000027ef5776b0] [c00000000012814c] .run_timer_softirq+0x2bc/0x3d0
[ 5748.047812] [c0000027ef5777b0] [c0000000000ad738] .__do_softirq+0x168/0x390
[ 5748.047885] [c0000027ef5778b0] [c0000000000adcc8] .irq_exit+0xc8/0x110
[ 5748.047958] [c0000027ef577930] [c00000000001d15c] .timer_interrupt+0x9c/0xd0
[ 5748.048030] [c0000027ef5779b0] [c000000000002658] decrementer_common+0x158/0x180
[ 5748.048116] --- interrupt: 901 at .arch_local_irq_restore+0x74/0x90
[ 5748.048116]     LR = .arch_local_irq_restore+0x74/0x90
[ 5748.048224] [c0000027ef577ca0] [c0000027ef577d30] 0xc0000027ef577d30 (unreliable)
[ 5748.048309] [c0000027ef577d10] [c00000000070887c] .cpuidle_enter_state+0xac/0x260
[ 5748.048393] [c0000027ef577dd0] [c0000000000f6c90] .cpu_startup_entry+0x410/0x460
[ 5748.048478] [c0000027ef577ed0] [c000000000040b40] .start_secondary+0x310/0x340
[ 5748.048562] [c0000027ef577f90] [c000000000008b6c] start_secondary_prolog+0x10/0x14
[ 5748.048643] Instruction dump:
[ 5748.048680] 994d02d4 4bffff10 7fc3f378 4bfd5ff1 60000000 7fc4f378 7fe6fb78 7c651b78 
[ 5748.048799] 3c62ff75 3863afb8 48123721 60000000 <0fe00000> 39200001 3d02fff0 99282b88 
[ 5748.048920] ---[ end trace a04deb5eef8eba41 ]---
[ 5748.385369] mlx4_en: eth13:   frag:0 - size:1518 prefix:0 align:0 stride:1536
[ 5760.841519] mlx4_en: eth13: CQE error - vendor syndrome: 0x6f syndrome: 0x2
[ 5781.165457] mlx4_en: eth13: CQE error - vendor syndrome: 0x6f syndrome: 0x2
[ 5781.315631] mlx4_en: eth13: CQE error - vendor syndrome: 0x6f syndrome: 0x2
[ 5782.165413] mlx4_en: eth13: CQE error - vendor syndrome: 0x6f syndrome: 0x2



>>
>> But for mlx4_en, I am not sure I could raise the debug level with ethtool,
>> since the ethernet driver may not work properly. Actually I am not sure how to
>> raise the level with ethtool. Could you give me an example?
>
># ethtool -s ens5f1d1 msglvl 0xffff
>
>>
>>>>
>>>> And this error is reported from VF always. After the error, the other network
>>>> interface seems can't function.
>>>>
>>>>>
>>>>>Amir.
>>>>
>>>> --
>>>> Richard Yang
>>>> Help you, Help me
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> Richard Yang
>> Help you, Help me
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Richard Yang
Help you, Help me
