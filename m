From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH v2 net-next af-packet 1/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Thu, 7 Jul 2011 09:04:58 -0400
Message-ID: <CAAsGZS4Y=-GSmP+2iYtd+V3RcE2+PpaStBzW7R7TDip7U-rdvA@mail.gmail.com>
References: <CAAsGZS5vvmb_qX+cG507=hU_+kwnowEEojXGNMt5ShEZ9+ZeAA@mail.gmail.com>
	<20110705.080123.2174577714045488116.davem@davemloft.net>
	<CAAsGZS67G8H5NLBxQTY88+T1cRQ3aiwBXK5qa8SJ_TbQ7xqvhw@mail.gmail.com>
	<20110707.001301.1054777374178479078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, joe@perches.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110707.001301.1054777374178479078.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 7, 2011 at 3:13 AM, David Miller <davem@davemloft.net> wrot=
e:

> Get rid of __packed__, it's going to kill performance on RISC
> platforms. =C2=A0If you use __packed__, regardless of the actual alig=
nment,

The performance boost has been achieved by amortizing the cost of
static spin-wait/poll and not by shrinking the data-set.


> the compiler must assume that each part of the struct "might" be
> unaligned. =C2=A0So on architectures such as sparc where alignment ma=
tters,
> a word is going to be accessed by a sequence of byte loads/stores.
>
Haven't worked with sparc so I didn't know. Thanks for the insight.
One also needs to analyze both the user/kernel components.The app
reads the header(hdr_size <<< blk_size) just once and then walks the
entire block. Apps operate on local copy of the variable and not on
the header.

kernel components - almost everything is cached in kbdq_core. block is
updated while closing.

> Do not use packed unless absolutely enforced by a protocol or hardwar=
e
> data structure, it's evil.
>
Depends. Why not evaluate on case-by-case basis? All I need to do is
pass this definition of the header around and only mandate how wide
the fields should be.
Once packed, I don't need to worry about padding on different
OS's/arch's. All I care about is the offset to the first pkt and other
details. The block says - you provide me offset to the first packet
and I will start walking the packets.

Another way to look at it - you pack something and then no padding is
needed(not the right example because every pkt-header will be
byte-sequenced if packed but you get the idea) :
http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcomm=
it;h=3D13fcb7bd322164c67926ffe272846d4860196dc6


Chetan Loke
