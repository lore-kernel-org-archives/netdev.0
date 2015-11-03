From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Resource leak in unshare
Date: Mon, 02 Nov 2015 16:03:07 -0800
Message-ID: <1446508987.23275.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
	 <87oafcrzsa.fsf@x220.int.ebiederm.org>
	 <1446494052.23275.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Graf <tgraf@suug.ch>,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446494052.23275.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-02 at 11:54 -0800, Eric Dumazet wrote:
> On Mon, 2015-11-02 at 13:01 -0600, Eric W. Biederman wrote:
> > Dmitry Vyukov <dvyukov@google.com> writes:
> > 
> > > Hello,
> > >
> > > I am hitting the following warnings on
> > > bcee19f424a0d8c26ecf2607b73c690802658b29 (4.3):
> > 
> > Do you have any trace of the earlier failures?
> > 
> > This appears to be something caused by an earlier failure (possibly
> > whatever fails to allocate memory).  Having network devices present
> > but being in the generic cleanup routines is wrong.
> > 
> > If there is no additional information can you please rerun with the
> > following change applied?  That should at least report which function is
> > failing, and give us a good clue where to start debugging this.
> 
> At first, I would say sit is leaking percpu memory
> 
> Load sit module, then :
> 
> while :
> do
> ip netns add foo
> ip netns del foo
> done
> 
> Will eat all memory eventually.
> 
> ipip6_tunnel_init() and ipip6_fb_tunnel_init() are _both_ called for the
> sit0 device, this looks very wrong.
> 
> 

This memleak might have been added in commit
ebe084aafb7e93adf210e80043c9f69adf56820d
("sit: Use ipip6_tunnel_init as the ndo_init function.")

I'll send a patch asap, if nothing more urgent preempts me today...
