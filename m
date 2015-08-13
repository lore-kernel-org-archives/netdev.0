From: Calvin Owens <calvinowens@fb.com>
Subject: Re: [PATCH] net: Use SK_MEM_QUANTUM as minimum for tcp/udp rmem/wmem
Date: Thu, 13 Aug 2015 14:07:04 -0700
Message-ID: <20150813210704.GA3055575@mail.thefacebook.com>
References: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
 <20150809.224114.818332231954008575.davem@davemloft.net>
 <20150811033406.GA1136819@mail.thefacebook.com>
 <20150810.204630.1903301700926701432.davem@davemloft.net>
 <20150812045420.GA3908557@mail.thefacebook.com>
 <1439389261.29802.3.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALh4rZqte0muVz0YLBVnsb9xzMh-xjKG8wmbi9Yo=9ge6z90HQ@mail.gmail.com>
 <1439401585.29802.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Sorin Dumitru <sorin@returnze.ro>,
	Sorin Dumitru <sdumitru@ixiacom.com>,
	David Miller <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439401585.29802.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08/12 at 10:46 -0700, Eric Dumazet wrote:
> On Wed, 2015-08-12 at 20:00 +0300, Sorin Dumitru wrote:
> 
> > Would clamping the values to a min value, like setsockopt(SO_SNDBUF)
> > does, be an option?
> > I still find it odd that SO_SNDBUF limits you, while the /proc
> > interface doesn't. If you think it's
> > too much, I'm ok with reverting it since it affects scripts.
> > 
> > On those arches where PAGE_SIZE == 64K(or > 16K) it looks like we have
> > tcp_wmem[1]
> > smaller than tcp_wmem[0]. Shouldn't we do something about this?
> 
> As long as we do not crash if/when root user changes /proc/sys/net
> settings, we are good.

Using "1 1 1" for tcp_{r,w}mem seems not to explode, so this sounds good
to me. I'll send a new patch reverting the original.

Thanks,
Calvin

> I would not care if performance is bad if root does something really
> stupid. root user is supposed to not mess things just for fun.
