From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net] r8152: Fix broken RX checksums.
Date: Mon, 31 Oct 2016 09:24:23 -0400
Message-ID: <5fca7aed-c6d5-85f0-0fad-f8eea384e613@pobox.com>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
 <20161030.205755.1198665157526465556.davem@davemloft.net>
 <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
 <20161030.235342.134481656830778556.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-10-31 04:14 AM, Hayes Wang wrote:
>
> Our hw engineer says only VER_01 has the issue about rx checksum.
> I need more information for checking it.

I've been doing driver work for Linux since 1991,
and learned long ago not to trust engineering specs 100%.

Get yourself a Raspberry Pi v1, set up an NFSROOT root filesystem for it,
and boot/run from that using the ethernet dongle to connect.

It should segfault like crazy when hardware RX checksums are enabled.

Definitely something wrong there, and whatever it is goes away
when RX checksums are disabled in the driver.

I have two theories as to why this happens:

1) The hardware buffer on the dongle overflows because the slow host CPU
does not empty it quickly enough.  This results in a bad checksum on the
final/truncated packet in the buffer.  The chip does not detect this.

2) Perhaps the device driver is looking at the wrong bits.

Either way, this results in data corruption and until otherwise fixed,
it is safest to just not enable RX checksums.

If it happens on a slow embedded CPU, then it can also happen on a heavily
loaded Intel/AMD CPU -- just a lot less frequently.

Cheers
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
