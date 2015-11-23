From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Deadlock between bind and splice
Date: Mon, 23 Nov 2015 10:21:27 +0100
Message-ID: <1448270487.3976105.447364665.43219C16@webmail.messagingengine.com>
References: <CACT4Y+brDX=C15jSs33zGaCBt2BDPPzBcgqtKA2dYMdviYjKww@mail.gmail.com>
 <1446824535.4184.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151110023854.GZ22011@ZenIV.linux.org.uk>
 <20151110025906.GA22011@ZenIV.linux.org.uk>
 <CACT4Y+bS2w3VUgb3MYe3epx7qbiu7VSNhW2CbXwwRSzmsSH2cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Dmitry Vyukov <dvyukov@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bS2w3VUgb3MYe3epx7qbiu7VSNhW2CbXwwRSzmsSH2cw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 23, 2015, at 09:32, Dmitry Vyukov wrote:
> On Tue, Nov 10, 2015 at 3:59 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Tue, Nov 10, 2015 at 02:38:54AM +0000, Al Viro wrote:
> >> On Fri, Nov 06, 2015 at 07:42:15AM -0800, Eric Dumazet wrote:
> >>
> >> > Thank you for this report.
> >> >
> >> > pipe is part of fs, not net ;)
> >>
> >> AF_UNIX bind() vs. socketpair() interplay, OTOH...
> >
> > FWIW, BSD folks unlock the socket for the duration of mknod - mark it as
> > "somebody's trying to bind it" to avoid the fun with racing double bind(),
> > but that's about it.  Tempting, to be honest...
> >
> > BTW, why does unix_autobind() do allocation under ->readlock?  The allocation
> > will be normally used - that if (u->addr) return; part is just dealing with
> > an unlikely race, as far as I can see...
> 
> 
> Hello,
> 
> This is still happening periodically for me. Is there a proposed fix?
> I could test it.

No, we currently have no fix for that report. :/
