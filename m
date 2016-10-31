From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net] r8152: Fix broken RX checksums.
Date: Sun, 30 Oct 2016 22:07:25 -0400
Message-ID: <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
References: <987cfbab-2b48-e28c-1706-967cb2051d63@pobox.com>
 <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
 <20161030.205755.1198665157526465556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161030.205755.1198665157526465556.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-10-30 08:57 PM, David Miller wrote:
> From: Mark Lord <mlord@pobox.com>
> Date: Sun, 30 Oct 2016 19:28:27 -0400
> 
>> The r8152 driver has been broken since (approx) 3.16.xx
>> when support was added for hardware RX checksums
>> on newer chip versions.  Symptoms include random
>> segfaults and silent data corruption over NFS.
>>
>> The hardware checksum logig does not work on the VER_02
>> dongles I have here when used with a slow embedded system CPU.
>> Google reveals others reporting similar issues on Raspberry Pi.
>>
>> So, disable hardware RX checksum support for VER_02, and fix
>> an obvious coding error for IPV6 checksums in the same function.
>>
>> Because this bug results in silent data corruption,
>> it is a good candidate for back-porting to -stable >= 3.16.xx.
>>
>> Signed-off-by: Mark Lord <mlord@pobox.com>
> 
> Applied and queued up for -stable, thanks.

Thanks.  Now that this is taken care of, I do wonder if perhaps
RX checksums ought to be enabled at all for ANY versions of this chip?

My theory is that the checksums probably work okay most of the time,
except when the hardware RX buffer overflows.

In my case, and in the case of the Raspberry Pi, the receiving CPU
is quite a bit slower than mainstream x86, so it can quite easily
fall behind in emptying the RX buffer on the chip.
The only indication this has happened may be an incorrect RX checksum.

This is only a theory, but I otherwise have trouble explaining
why we are seeing invalid RX checksums -- direct cable connections
to a switch, shared only with the NFS server.  No reason for it
to have bad RX checksums in the first place.

Should we just blanket disable RX checksums for all versions here
unless proven otherwise/safe?

Anyone out there know better?

Cheers
Mark
