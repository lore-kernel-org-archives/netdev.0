From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: sctp: clone options to avoid use after free
Date: Wed, 09 Dec 2015 07:59:42 -0800
Message-ID: <1449676782.9768.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+YjXJoh3uGDp=FJkYVnjaMxFSPY252ptbDGZ-LQ9JAEWw@mail.gmail.com>
	 <CANn89i+V-GeD3zCzGPAo4jY8Z6iTjFN3U1ixG44WyKKLOZ9Txw@mail.gmail.com>
	 <20151209145917.GA3884@mrl.redhat.com>
	 <CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
	 <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBE9A61@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
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
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBE9A61@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-09 at 15:49 +0000, David Laight wrote:
> > SCTP is lacking proper np->opt cloning at accept() time.
> > 
> > TCP and DCCP use ipv6_dup_options() helper, do the same in SCTP.
> > 
> > We might later factorize this code in a common helper to avoid
> > future mistakes.
> 
> I'm wondering what the real impact of this and the other recent
> SCTP bugs/patches is on real workloads?
> We have enough trouble getting our customers to use kernels
> later that the 2.6.18 based RHEL5 - without having to persuade
> them to use kernels that contain very recent fixes.

It all depends if your customers let (hostile ?) people run programs on
the boxes.

I wont run the program on my laptop just for the fun of making it crash,
but I guess Cloud providers might be worried, once exploits are public.
