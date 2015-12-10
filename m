From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: sctp: clone options to avoid use after free
Date: Thu, 10 Dec 2015 07:58:17 -0800
Message-ID: <1449763097.9768.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+YjXJoh3uGDp=FJkYVnjaMxFSPY252ptbDGZ-LQ9JAEWw@mail.gmail.com>
	 <CANn89i+V-GeD3zCzGPAo4jY8Z6iTjFN3U1ixG44WyKKLOZ9Txw@mail.gmail.com>
	 <20151209145917.GA3884@mrl.redhat.com>
	 <CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
	 <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBE9A61@AcuExch.aculab.com>
	 <1449676782.9768.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBE9B1C@AcuExch.aculab.com>
	 <566860BC.4040604@gmail.com> <56687EBB.5040108@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBEA7A3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBEA7A3@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-12-10 at 12:26 +0000, David Laight wrote:

> Yes, I'm worried about whether our M3UA code is likely to crash customer
> systems, not whether hostile applications can crash it.
> These boxes ought to be on private networks since the sigtran protocols
> themselves have nothing that even gives a hint of security.

As long as the listener socket is kept as is, meaning that the only use
of it is the poll()/select()/accept() system calls, you are safe.

The bug is about having a fuzzer, specifically playing games with multi
threads so that the listener ipv6 options are changed after accept(). 

This should not really happen in real world applications : If ipv6
options need to be set on listener, they are set before first accept()
is performed, and not unset until application exits and kill all
sessions.

BTW, are you even using IPv6 SCTP sessions ?
