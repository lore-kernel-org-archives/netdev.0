From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net] r8152: Fix broken RX checksums.
Date: Wed, 9 Nov 2016 08:19:31 -0500
Message-ID: <d261ef1c-b6d1-18a9-572a-2cf6978ff259@pobox.com>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
 <20161030.205755.1198665157526465556.davem@davemloft.net>
 <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
 <20161030.235342.134481656830778556.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
 <201611030159.uA31x0np004648@rtits1.realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20104878A@RTITMBSV03.realtek.com.tw>
 <ddbc14e2-dfb5-01f2-0d5b-5b409a01160f@pobox.com>
 <201611041425.uA4EPwCw018176@rtits1.realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20104A0FD@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB20104A0FD@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-09 08:09 AM, Hayes Wang wrote:
> Mark Lord [mailto:mlord@pobox.com]
..
>> The MTU/MRU on this link is the standard 1500 bytes, so a pkt_len of 2045 isn't
>> valid here.
>> And the rx_desc values look an awful lot like the rx_data values that follow it.
>>
>> There's definitely more broken here than just TCP RX checksums.
> 
> I don't think it is the issue of our hw. If it happens, windows or
> other OS may have problems, too. It is like the memory issue described
> in commit 990c9b347245("Merge branch 'r8152-fixes'"). It seems that
> the data in memory is not same with the one from the device.

I am still doing long-term testing of various tweaks to the driver,
and can now confirm that changing from kmalloc() to usb_alloc_coherent()
vastly improves reliability, and re-enabling RX checksums works fine
with that change.

However, even with coherent URB buffers, I still see the occasional bad rx_desc:
like, twice in 36 hours of continuous bashing at it.

So having code in the driver to sanitize the rx_desc is essential.
My current test code (shared with Hayes already) includes validation of various
key fields of the rx_desc, and detects when the chip/driver/whatever gets confused.

Hopefully r8152.c will get updated to take more care before trusting
what it sees in the rx_desc fields.

Cheers
-- 
Mark Lord
mlord@pobox.com
