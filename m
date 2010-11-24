From: Li Yang-R58472 <r58472@freescale.com>
Subject: RE: ucc_geth: transmit queue timeout at half-duplex mode
Date: Wed, 24 Nov 2010 04:05:06 -0700
Message-ID: <3F607A5180246847A760FD34122A1E0502AF23@039-SN1MPN1-003.039d.mgd.msft.net>
References: <1863FF2A13D0E048900A981ACDE485000281810792@ExchN1.riedel.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>
To: "Schmitz, Andreas" <Andreas.Schmitz@riedel.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:54780
	"EHLO VA3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753095Ab0KXLE1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 06:04:27 -0500
Received: from mail52-va3 (localhost.localdomain [127.0.0.1])	by
 mail52-va3-R.bigfish.com (Postfix) with ESMTP id 4067E12B8093	for
 <netdev@vger.kernel.org>; Wed, 24 Nov 2010 10:59:41 +0000 (UTC)
Received: from VA3EHSMHS027.bigfish.com (unknown [10.7.14.246])	by
 mail52-va3.bigfish.com (Postfix) with ESMTP id ED6E81A804F	for
 <netdev@vger.kernel.org>; Wed, 24 Nov 2010 10:59:40 +0000 (UTC)
Received: from az33smr02.freescale.net (az33smr02.freescale.net
 [10.64.34.200])	by de01egw01.freescale.net (8.14.3/8.14.3) with ESMTP id
 oAOB5sH6012690	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 04:05:55 -0700
 (MST)
Received: from az33exm22.fsl.freescale.net (az33exm22.am.freescale.net
 [10.64.32.10])	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id
 oAOB4C9K001135	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 05:04:12 -0600
 (CST)
Content-Language: en-US
Content-Class: urn:content-classes:message
In-Reply-To: <1863FF2A13D0E048900A981ACDE485000281810792@ExchN1.riedel.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Subject: ucc_geth: transmit queue timeout at half-duplex mode
>
>Hi all,
>on my MPC8321E with linux-2.6.36 I get this netdev watchdog warning
>"NETDEV WATCHDOG: eth0 (of:ucc_geth): transmit queue 0 timed out" if the
>link mode is half-duplex.
>The warning is caused, because all Tx BDs are full and packet transmission
>is stopped with netif_stop_queue() in ucc_geth_start_xmit().
>
>You can reproduce the bug in the following way:
>- Connect to a switch, that supports only 10baseT, or set the mode
>manually with "mii-diag -F 10baseT".
>- Open a telnet session to the target. Generate higher traffic with
>executing maybe "cat /proc/interrupts" many times.
>- After some tries the ethernet connection will be down, then again after
>approx. 30s seconds the netdev watchdog will dump the warning.
>
>It is unclear to me why the TxBDs get full. Due to missing "Tx buffer
>sent" interrupts, it seems that the QE stops the transmission.
>
>I found some issue in the errata: "QE_ENET20: UEC may stop transmitting
>after late collision". But UCCE[TXE] is never set in this case.
>
>Thank you for your help in advance and best regards,

I believe your problem is related to an errata for 8321:
High Tx Virtual FIFO threshold size can cause UCC to halt.

Reducing the UTFTT might fix the problem.

If you are interested, I can sent you the detailed errata off the thread.

- Leo


