From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
Date: Thu, 18 Jun 2015 07:35:53 -0700
Message-ID: <CANn89iLr2iNV3VjA4POPpfsmOpyB7jP2-wPiAkCOcA+Oh+2=5A@mail.gmail.com>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
	<557AA834.8070503@suse.cz>
	<alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
	<20150618143019.GE5858@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Shaohua Li <shli@fb.com>,
	netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	kernel-team <Kernel-team@fb.com>, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com
To: Michal Hocko <mhocko@suse.cz>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150618143019.GE5858@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 18, 2015 at 7:30 AM, Michal Hocko <mhocko@suse.cz> wrote:

> Abusing __GFP_NO_KSWAPD is a wrong way to go IMHO. It is true that the
> _current_ implementation of the allocator has this nasty and very subtle
> side effect but that doesn't mean it should be abused outside of the mm
> proper. Why shouldn't this path wake the kswapd and let it compact
> memory on the background to increase the success rate for the later
> high order allocations?

I kind of agree.

If kswapd is a problem (is it ???) we should fix it, instead of adding
yet another flag to some random locations attempting
memory allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
