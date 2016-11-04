From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net] r8152: Fix broken RX checksums.
Date: Fri, 4 Nov 2016 09:50:20 -0400
Message-ID: <d1ac848d-d36d-c81a-e0a2-4cab2d7382cd@pobox.com>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
 <20161030.205755.1198665157526465556.davem@davemloft.net>
 <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
 <20161030.235342.134481656830778556.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
 <201611030159.uA31x0np004648@rtits1.realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20104878A@RTITMBSV03.realtek.com.tw>
 <ddbc14e2-dfb5-01f2-0d5b-5b409a01160f@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ddbc14e2-dfb5-01f2-0d5b-5b409a01160f@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yeah, the device or driver is definitely getting confused with rx_desc structures.
I added code to check for unlikely rx_desc values, and it found this for starters:

rx_desc: 00480801 00480401 00480001 0048fc00 0048f800 0048f400 pkt_len=2045
rx_data: 00 f0 48 00 00 ec 48 00 00 e8 48 00 00 e4 48 00 00 e0 48 00 00 dc 48 00 00 d8 48 00 00 d4 48 00
rx_data: 00 d0 48 00 00 cc 48 00 00 c8 48 00 00 c4 48 00 00 c0 48 00 00 bc 48 00 00 b8 48 00 00 b4 48 00
rx_data: 00 b0 48 00 00 ac 48 00 00 01 00 00 81 ed 00 00 00 01 00 00 00 00 00 00 00 00 00 02 4d ac 00 00
rx_data: 10 00 ff ff ff ff 00 00 01 28 83 d6 ff 6d 00 20 25 b1 58 1b 68 ff 00 05 20 01 56 41 17 35 00 00
...

The MTU/MRU on this link is the standard 1500 bytes, so a pkt_len of 2045 isn't valid here.
And the rx_desc values look an awful lot like the rx_data values that follow it.

There's definitely more broken here than just TCP RX checksums.

-ml
