From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 3/4] secure_seq: use SipHash in place of MD5
Date: Mon, 9 Jan 2017 13:18:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB025AC4D@AcuExch.aculab.com>
References: <20170107144057.15432-1-Jason@zx2c4.com>
 <20170107144057.15432-4-Jason@zx2c4.com>
 <20170107.163736.2224609477435674963.davem@davemloft.net>
 <20170107220911.GB8327@zzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jason@zx2c4.com" <Jason@zx2c4.com>,
        "jeanphilippe.aumasson@gmail.com" <jeanphilippe.aumasson@gmail.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ak@linux.intel.com" <ak@linux.intel.com>,
        "tom@herbertland.com" <tom@herbertland.com>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "luto@kernel.org" <luto@kernel.org>
To: 'Eric Biggers' <ebiggers3@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170107220911.GB8327@zzz>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Biggers
> Sent: 07 January 2017 22:09
..
> Out of curiosity, is this actually a solvable problem, e.g. by making the code
> using the XMM registers responsible for saving and restoring the ones clobbered,
> or by optimizing kernel_fpu_begin()/kernel_fpu_end()?  Or does it in fact remain
> impractical for such instructions to be used for applications like this one?

I think it should be possible to fast-save a couple of FP registers
by telling the IPI save code where to save them from (to load
into a different cpu).
But there might be issues with other parts of the FP state.
This might be ok provided the kernel doesn't actually use FP instructions.

(I thought about this when adding AVX support to NetBSD.)

	David
