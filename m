From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net] r8152: Fix broken RX checksums.
Date: Thu, 3 Nov 2016 07:43:36 -0400
Message-ID: <ddbc14e2-dfb5-01f2-0d5b-5b409a01160f@pobox.com>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
 <20161030.205755.1198665157526465556.davem@davemloft.net>
 <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
 <20161030.235342.134481656830778556.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
 <201611030159.uA31x0np004648@rtits1.realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20104878A@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB20104878A@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-03 04:56 AM, Hayes Wang wrote:
> Mark Lord [mailto:mlord@pobox.com]
>> Sent: Thursday, November 03, 2016 2:30 AM
>> To: Hayes Wang; David Miller
> [...]
>> I have poked at it some more, and thus far it appears that it is
>> only necessary to disable TCP rx checksums.  The system doesn't crash
>> when only IP/UDP checksums are enabled, but does when TCP checksums are on.
>>
>> This happens regardless of whether RX_AGG is disabled or enabled,
>> and increasing/decreasing the number of RX URBs (RTL8152_MAX_RX)
>> doesn't seem to affect it.
> 
> I test Raspberry Pi v1, but I couldn't boot with NFSROOT through
> both onboard nic and RTL8152. I get following error.
> 
>    VFS: Unable to mount root fs via NFS, trying floppy.
>    Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(2,0)
> 
> However, if I start the system without NFSROOT, I could mount the nfs fs.
> Any idea?

Rather than getting caught up in all of that,
you could then just chroot to the mounted nfs fs
at that point, and continue on from there.

Eg.  chroot /mnt/nfsxxx /bin/sh

Running from NFS is probably not necessary though.
Instead, perhaps just run md5sum on every file on the nfs fs
from the Raspberry Pi, and then repeat the md5sum's on the server,
and compare the results for errors.

The system I am using the dongle with is a custom embedded board,
but I think the important thing is that it has a slow-ish CPU,
which means it is more prone to having the on-chip RX FIFO overflow.
It is also big-endian rather than little-endian, though that seems
to be correctly handled already in the device driver.

I will try the md5sum test on an x86 box for comparison.

Cheers
-- 
Mark Lord
