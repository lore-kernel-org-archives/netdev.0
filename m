From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Tue, 16 Mar 2010 16:20:26 +0100
Message-ID: <1268752826.3094.48.camel@edumazet-laptop>
References: <20100307192305.GA598@elte.hu>
	 <20100308125122.GA11242@redhat.com>
	 <1268686865.2824.4.camel@edumazet-laptop>
	 <1268699602.2824.14.camel@edumazet-laptop>
	 <20100316145914.GB3332@swordfish.minsk.epam.com>
	 <1268751933.3094.45.camel@edumazet-laptop>
	 <20100316151023.GC3332@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100316151023.GC3332@swordfish.minsk.epam.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 16 mars 2010 =C3=A0 17:10 +0200, Sergey Senozhatsky a =C3=A9cr=
it :

> [...]
> >> NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
> Isn't it r8169 related?
>=20

This is tx side which seems blocked for more than 6 seconds.

To really test the patch, you need following setup :

machine A with r8169 NIC, patch applied, receiver of pktgen flood.

machine B with any NIC, preferably a not buggy one, doing the pktgen
flood to machine A

If machine A survives, my patch is tested and ok.

If machine B crashes, we have another problem to investigate
