From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Mon, 12 Dec 2016 16:19:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB023BF78@AcuExch.aculab.com>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
        <CAA93jw7hcmkcyD=t4VRrQFfHk+n+EkSVgY6KFDq0_-DGpMADYw@mail.gmail.com>
        <20161207.135127.789629809982860453.davem@davemloft.net>
        <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
        <040bcdb2-2725-c8de-11d9-a4f77b75d9d8@nbd.name>
 <yw1x37hvykzk.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        "WireGuard mailing list" <wireguard@lists.zx2c4.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
To: =?Windows-1252?B?J03lbnMgUnVsbGflcmQn?= <mans@mansr.com>,
        Felix Fietkau <nbd@nbd.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1x37hvykzk.fsf@unicorn.mansr.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Måns Rullgård
> Sent: 10 December 2016 13:25
...
> I solved this problem in an Ethernet driver by copying the initial part
> of the packet to an aligned skb and appending the remainder using
> skb_add_rx_frag().  The kernel network stack only cares about the
> headers, so the alignment of the packet payload doesn't matter.

That rather depends on where the packet payload ends up.
It is likely that it will be copied to userspace (or maybe
into some aligned kernel buffer).
In which case you get an expensive misaligned copy.

Encapsulation protocols not using headers that are multiples
of 4 bytes is as stupid as ethernet hardware that can't place
the mac address on a 4n+2 boundary.
The latter is particularly stupid when it happens on embedded
silicon with a processor that can only do aligned memory accesses.
What do the hardware engineers think the ethernet interface will
be used for!

	David
