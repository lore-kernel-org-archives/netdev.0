From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 07:07:56 +0200
Message-ID: <43323C2C.8070204@cosmosbay.com>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de> <432FDAC5.3040801@cosmosbay.com> <200509201830.20689.ak@suse.de> <433082DE.3060308@cosmosbay.com> <43308324.70403@cosmosbay.com> <4331CFA7.50104@cosmosbay.com> <Pine.LNX.4.63.0509220017430.6397@excalibur.intercode>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org, Andi Kleen <ak@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030218AbVIVFID@vger.kernel.org>
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.63.0509220017430.6397@excalibur.intercode>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris a =E9crit :
>=20
> Do you have any performance measurements?

Yes, as I said in the first mail :

 >In oprofile results, ipt_do_table() was at the first position.
 >It is now at 6th position, using 1/3 of the CPU it was using before.
 >(Tests done on a dual Xeon i386 and a dual Opteron x86_64)

On the dual opteron machine, with 40.000 packets coming per second, and=
 35.000=20
sent per second, the numbers were : 12.8 % before the patches, 4.4 % af=
ter the=20
patches.

I dont have separate perf measurements for each patch.

Considering the fact that I inlined the read_lock_bh() call (not displa=
yed in=20
oprofile results, probably because of the special .spinlock.text sectio=
n) that=20
should have increased the profile of ipt_do_table(), thats a lot of CPU=
 cycles=20
  and mem bandwitdh that are available for other jobs.

Eric
