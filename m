From: =?UTF-8?B?TWlsb8WhIEd5bVJL?= <m.kloucek.m@gmail.com>
Subject: Re: pandaboard brctl oops
Date: Tue, 2 Aug 2011 23:18:02 +0200
Message-ID: <CAPOFEBOnaqn_gaGNu33_JhiEtGo8R_jyjkHCTLv02KmnbhvzmQ@mail.gmail.com>
References: <201108012325.17312.marek.vasut@gmail.com>
	<4E375FD6.4090404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4E375FD6.4090404@cn.fujitsu.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/2/11, Shan Wei <shanwei@cn.fujitsu.com> wrote:
> hi
>
> Marek Vasut wrote, at 08/02/2011 05:25 AM:
>> Hi,
>>
>> recently a friend of mine sent me this backtrace. I put him in CC so
>> please any
>> subsequent questions shall be forwarded to him.
>>
>> He claims this happens on pandaboard.
>>
>> Cheers
>>
>> root@box:~# brctl addif br0 eth0
>> [   77.795776] Unable to handle kernel NULL pointer dereference at virtual
>>
>> address 00000000
>> [   77.804321] pgd = ee8d4000
>> [   77.807312] [00000000] *pgd=af8e6831, *pte=00000000, *ppte=00000000
>> [   77.813995] Internal error: Oops: 80000007 [#1] SMP
>> [   77.819122] last sysfs file: /sys/devices/virtual/net/br0/uevent
>> [   77.825439] Modules linked in: bridge stp llc wl12xx_sdio wl12xx
>> [   77.831787] CPU: 0    Not tainted  (2.6.39.2-omap4 #3)
>> [   77.837188] PC is at 0x0
>> [   77.839904] LR is at br_change_mtu+0x64/0x7c [bridge]
>
> This one has been fixed in latest kernel.
>
> commit 6407d74c5106bb362b4087693688afd34942b094
> Author: Alexander Holler <holler@ahsoftware.de>
> Date:   Tue Jun 7 00:51:35 2011 -0700
>
>     bridge: provide a cow_metrics method for fake_ops
>
>     Like in commit 0972ddb237 (provide cow_metrics() methods to blackhole
>     dst_ops), we must provide a cow_metrics for bridges fake_dst_ops as
>     well.
>
>     This fixes a regression coming from commits 62fa8a846d7d (net: Implement
>     read-only protection and COW'ing of metrics.) and 33eb9873a28 (bridge:
>     initialize fake_rtable metrics)
>
>     ip link set mybridge mtu 1234
>
> --
> Best Regards
> -----
> Shan Wei
>

I expected something rare or architecture-dependent, because I had no
problems when adding wlan0 to the bridge

Chery-picking the commit indeed fixed the problem
thanks for such quick reply
