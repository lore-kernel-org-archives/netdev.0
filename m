From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in
 __skb_try_recv_datagram
Date: Tue, 05 Jan 2016 06:39:57 -0800
Message-ID: <1452004797.8255.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	 <87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
	 <20151229.150843.2021692616139434395.davem@davemloft.net>
	 <CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
	 <CANn89iLpuz4nP+hPoGUHY8KSv=GwSE1x13D3qDeAQDJjV-S7pw@mail.gmail.com>
	 <CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
	 <CAM_iQpVQNPQ1LNvG+h3=UvTM9Lm-adhryQk-ad4aeckHS-V0ew@mail.gmail.com>
	 <CAEnXRPsH-eTwwd7FvODL+0Qu9CLY-uGYT9z81cH-by5baEdbhg@mail.gmail.com>
	 <1451921108.8255.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEnXRPu8As9sr44JcjqVW-omN8BshtzhZZd73cr7vFXLTVPFWQ@mail.gmail.com>
	 <1452003299.8255.87.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEnXRPuL6bUJWvJ=OWokHCvZkdcngaYmwX3wV70douDbnG8bVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Jacob Siverskog <jacob@teenage.engineering>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnXRPuL6bUJWvJ=OWokHCvZkdcngaYmwX3wV70douDbnG8bVw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-05 at 15:34 +0100, Jacob Siverskog wrote:
> On Tue, Jan 5, 2016 at 3:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> >
> > You might build a kernel with KASAN support to get maybe more chances to
> > trigger the bug.
> >
> > ( https://www.kernel.org/doc/Documentation/kasan.txt )
> >
> 
> Ah. Doesn't seem to be supported on arm(32) unfortunately.

Then you could at least use standard debugging features :

CONFIG_SLAB=y
CONFIG_SLABINFO=y
CONFIG_DEBUG_SLAB=y
CONFIG_DEBUG_SLAB_LEAK=y

(Or equivalent SLUB options)

and

CONFIG_DEBUG_PAGEALLOC=y

(If arm(32) has CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y)
