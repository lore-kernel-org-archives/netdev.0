From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [2.6.28] NULL pointer dereference at get_stats()
Date: Wed, 31 Dec 2008 00:16:18 +0900
Message-ID: <2f11576a0812300716k32572abel2d38fff6153b7a0e@mail.gmail.com>
References: <200812302153.ECH86976.MFLOQFJHtSOOFV@I-love.SAKURA.ne.jp>
	 <2f11576a0812300528t6ed12fccg8698d33dc778b9c3@mail.gmail.com>
	 <200812302338.GDF34307.JOOMSFVQHFLFOt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:18090 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbYL3PQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 10:16:19 -0500
In-Reply-To: <200812302338.GDF34307.JOOMSFVQHFLFOt@I-love.SAKURA.ne.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

>> it doesn't have any network card initialization log, but kernel
>> crashed in network driver.
>> in addition, loaded module list indicate your network card is pcnet32,
>> but pcnet32 doesn't have
>> get_stats() function. (instead, it has pcnet32_get_stats() )
>
> I think pcnet32 is unrelated.
> It seems to me that the problem is loopback device.

my ia32 box can't reproduce your problem although loopback doesn't
depend on any hardware.
I suspect vmware issue.


>
> I added "init=/bin/bash" and tried below commands.
> ----------------------------------------
> # lsmod
> Module                  Size  Used by
> mptspi                 19208  1
> mptscsih               33152  1 mptspi
> mptbase                74084  2 mptspi,mptscsih
> scsi_transport_spi     23296  1 mptspi
> sd_mod                 27416  2
> scsi_mod              138260  4 mptspi,mptscsih,scsi_transport_spi,sd_mod
> ext3                  109576  1
> jbd                    43924  1 ext3
> uhci_hcd               22800  0
> ohci_hcd               23696  0
> ehci_hcd               33036  0
