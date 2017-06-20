From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Replace TXBB_SIZE
 multiplications with shift operations
Date: Tue, 20 Jun 2017 13:53:31 +0300
Message-ID: <d1bcb5cf-6854-066f-74c1-335fc3d02a21@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
 <1497526540-30028-10-git-send-email-tariqt@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0026944@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "kernel-team@fb.com" <kernel-team@fb.com>,
        Eric Dumazet <edumazet@google.com>
To: David Laight <David.Laight@ACULAB.COM>,
        'Tariq Toukan' <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0080.outbound.protection.outlook.com ([104.47.2.80]:4742
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751021AbdFTKxo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 06:53:44 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0026944@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20/06/2017 11:45 AM, David Laight wrote:
> From: Tariq Toukan
>> Sent: 15 June 2017 12:36
>> Define LOG_TXBB_SIZE, log of TXBB_SIZE, and use it with a shift
>> operation instead of a multiplication with TXBB_SIZE.
>> Operations are equivalent as TXBB_SIZE is a power of two.
>>
>> Performance tests:
>> Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
>>
>> Gain is too small to be measurable, no degradation sensed.
>> Results are similar for IPv4 and IPv6.
> 
> I can't imagine there is any difference at all.
> The compiler will use a shift for a 'multiply by a constant power of 2'.
Yeah i guess my compiler does that, because it's a constant known at 
compile-time.

> 
> ...
> If you want to save a few cycles I think the loop:
>> -		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE;
>> +		for (i = 0; i < tx_info->nr_txbb << LOG_TXBB_SIZE;
> requires the compiler generate code to read nr_txbb every
> iteration.
> Caching the values might help (unless it causes a different
> register spill).

That sounds good!
I'll prepare and send this after testing.
I'll also look for similar cases in driver.

> 
> 	David
> 

Thank you David!
