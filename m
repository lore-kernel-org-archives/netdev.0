From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: seeing strange values for tcp sk_rmem_alloc
Date: Thu, 03 Dec 2009 10:55:41 -0600
Message-ID: <4B17ED8D.7050409@nortel.com>
References: <4B15416A.2060202@nortel.com> <4B154B29.1030807@cosmosbay.com> <4B155252.1040604@nortel.com> <4B1557CC.4060503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755389AbZLCQ6Z@vger.kernel.org>
In-Reply-To: <4B1557CC.4060503@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2009 11:52 AM, Eric Dumazet wrote:

> But be careful of sender tcp stack : It might be delayed a bit,
> because it waits for receiver to open its window (slow start)
> 
> You probably need something like
> 
> while (1) {
> 	send(fd1, buffer, 2Kbytes);
> 	sleep(2); // let tcp stack flush its write buffers
> 	display_sk_rmem_alloc(fd2);
> }

Ah, that makes a difference.  But the results (see below) still look
odd.  For this test, /proc/sys/net/core/rmem_default is 118784.  For
some reason sk_rmem_alloc gets bumped by 16KB when I only send 2KB of
data, and it drops back down again every 6 packets.

Chris



used: 16848
used: 33696
used: 50544
used: 67392
used: 84240
used: 101088
used: 30736
used: 47584
used: 64432
used: 81280
used: 98128
used: 114976
used: 44624
used: 61472
used: 78320
used: 95168
used: 112016
used: 128864
used: 58512
used: 75360
used: 92208
used: 109056
used: 125904
used: 142752
used: 72400
used: 89248
used: 106096
used: 122944
used: 139792
used: 156640
used: 86288
used: 103136
used: 119984
used: 136832
used: 153680
used: 170528
used: 100176
used: 117024
used: 133872
used: 150720
used: 167568
used: 184416
used: 114064
used: 130912
used: 147760
used: 164608
used: 181456
used: 198304
used: 127952
used: 144800
used: 161648
used: 178496
used: 195344
used: 212192
used: 141840
used: 158688
used: 175536
used: 192384
used: 209232
used: 226080
used: 155728
used: 172576
used: 189424
used: 206272
used: 223120
used: 239968
used: 169616
used: 186464
used: 203312
used: 220160
used: 237008
used: 253856
used: 183504
used: 200352
used: 217200
used: 234048
used: 250896
used: 267744
used: 197392
used: 214240
used: 231088
used: 247936
used: 264784
used: 281632
used: 211280
used: 228128
used: 244976
