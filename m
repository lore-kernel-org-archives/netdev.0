From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] linux-2.6.28-rc3 regression: IRQ smp_affinities not
 respected
Date: Tue, 4 Nov 2008 22:45:43 -0800
Message-ID: <C27F8246C663564A84BB7AB343977242151F4B18B5@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <49113E31.8080106@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "'Eric Dumazet'" <dada1@cosmosbay.com>,
	"linux kernel" <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2602 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbYKEGpx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 01:45:53 -0500
In-Reply-To: <49113E31.8080106@cosmosbay.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Hi all
>
> One more problem it seems on 2.6.28-rc3
>
> I wanted to get maximal throughput from my machine on a
> network bench with 3 Gigabit
> links delivering 600.000 packets per second, so I tried to
> play with smp_affinity to
> dedicate one CPU for each NIC.
>
> It worked with 2.6.27, so there is a regression on this part.

I believe this may be the patch that broke it:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ce6fce4295ba727b36fdc73040e444bd1aae64cd

I don't remember all the details, but the Broadcom 5708 chip is
affected because it does not support MSI per-vector masking.

One way to get around is to disable MSI with bnx2 parameter
disable_msi=1.


