From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Deadlock between bind and splice
Date: Tue, 10 Nov 2015 02:59:06 +0000
Message-ID: <20151110025906.GA22011@ZenIV.linux.org.uk>
References: <CACT4Y+brDX=C15jSs33zGaCBt2BDPPzBcgqtKA2dYMdviYjKww@mail.gmail.com>
 <1446824535.4184.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151110023854.GZ22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-fsdevel@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151110023854.GZ22011@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2015 at 02:38:54AM +0000, Al Viro wrote:
> On Fri, Nov 06, 2015 at 07:42:15AM -0800, Eric Dumazet wrote:
> 
> > Thank you for this report.
> > 
> > pipe is part of fs, not net ;)
> 
> AF_UNIX bind() vs. socketpair() interplay, OTOH...

FWIW, BSD folks unlock the socket for the duration of mknod - mark it as
"somebody's trying to bind it" to avoid the fun with racing double bind(),
but that's about it.  Tempting, to be honest...

BTW, why does unix_autobind() do allocation under ->readlock?  The allocation
will be normally used - that if (u->addr) return; part is just dealing with
an unlikely race, as far as I can see...
