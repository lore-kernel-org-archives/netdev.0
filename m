From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 16:28:25 -0700
Message-ID: <482E1899.7020604@hp.com>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>	<20080515142154.0595e475@core>	<36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>	<20080515173939.1ec968be@core> <482C7DA3.1090809@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:9596 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbYEPX23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 19:28:29 -0400
In-Reply-To: <482C7DA3.1090809@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> The Treacherous Platform Module includes an RNG.
> 
> Someone (hi Jesse?) should implement support for TPM_GetRandom.
> 
> All the specs are public, and the hardware is already in users' hands.

My curiousity got the better of me, so I enabled the TPM (Infineon)

moe:~# dmesg | grep -i tpm
tpm_inf_pnp 00:05: Found TPM with ID IFX0101
tpm_inf_pnp 00:05: TPM found: config base 0xff5b804e, data base 
0xff5b8000, chip version 0x0006, vendor id 0x15d1 (Infineon), product id 
0x0006 (SLD 9630 TT 1.1)

on a system I had, and using whatever Debian Lenny (w 2.6.24-1 kernel) 
offers for trousers and tcsd etc, a bunch of help from some other HPers, 
and a hacked example program from an HP-UX document I pressed-on without 
much understanding and arrived at:

moe:~# time ./raj_example -c 1000
making 1000 Tspi_TPM_GetRandom calls of 16 bytes each

real    0m28.033s
user    0m0.000s
sys     0m0.000s


28.0033s / 1000 calls = 2.8 ms per call.  While this was happening top 
was reporting  1% CPU time in the tcsd.

I've no idea how much feeding /dev/random would want and how often, but 
there is some crude data on overhead for pulling random numbers out of 
at least one TPM.  Here is some varying of the number of bytes requested 
each time:

moe:~# for i in 1 16 32 64
 > do
 > time ./raj_example -c 1000 -r $i
 > done
making 1000 Tspi_TPM_GetRandom calls of 1 bytes each

real    0m24.146s
user    0m0.008s
sys     0m0.000s
making 1000 Tspi_TPM_GetRandom calls of 16 bytes each

real    0m28.032s
user    0m0.000s
sys     0m0.000s
making 1000 Tspi_TPM_GetRandom calls of 32 bytes each

real    0m28.032s
user    0m0.004s
sys     0m0.000s
making 1000 Tspi_TPM_GetRandom calls of 64 bytes each

real    0m36.032s
user    0m0.004s
sys     0m0.000s

rick jones
no, i don't plan on adding this to netperf :)
