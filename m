From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net] r8152: Fix broken RX checksums.
Date: Fri, 4 Nov 2016 08:13:59 -0400
Message-ID: <4365eeb3-8e83-4fdd-f277-25c84b7a5d37@pobox.com>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
 <20161030.205755.1198665157526465556.davem@davemloft.net>
 <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
 <20161030.235342.134481656830778556.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
 <008b7d7d-74af-0341-0c16-40aafde5a223@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <008b7d7d-74af-0341-0c16-40aafde5a223@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-02 02:29 PM, Mark Lord wrote:
>
> I have poked at it some more, and thus far it appears that it is
> only necessary to disable TCP rx checksums.  The system doesn't crash
> when only IP/UDP checksums are enabled, but does when TCP checksums are on.
>
> This happens regardless of whether RX_AGG is disabled or enabled,
> and increasing/decreasing the number of RX URBs (RTL8152_MAX_RX)
> doesn't seem to affect it.
>
..

I noticed that BIT(20) was not defined as anything for "opts3",
and so I added a line to rx_csum to check whether or not that bit
was ever set.

It triggered after a few thousand reset/reboot cycles with opts3
having the rather dubious looking value of an ASCII string: 0x5c7d7852.

So to me, it appears that the rx_desc's are getting mixed-up with data somewhere,
and when using hardware TCP checksums this doesn't get caught.  So perhaps the
checksums themselves are fine, but there's another bug (driver or hardware?)
that sneaks through when not doing software checksums.
