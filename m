From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 17:35:00 -0400
Message-ID: <CAATkVEw93KaUQuNJY9hxA+q2dxPb2AAxicojkjDfXDZU5VGxtg@mail.gmail.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
	<1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<5579FABE.4050505@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Shaohua Li <shli@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>, Kernel-team@fb.com,
	Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
	Joshua Hunt <johunt@akamai.com>, "Banerjee, Debabrata" <dbanerje@akamai.com>
To: Chris Mason <clm@fb.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <5579FABE.4050505@fb.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

There is no "background" it doesn't matter if this activity happens
synchronously or asynchronously, unless you're sensitive to the
latency on that single operation. If you're driving all your cpu's and
memory hard then this is work that still takes resources. If there's a
kernel thread with compaction running, then obviously your process is
not.

Your patch should help in that not every atomic allocation failure
should mean yet another run at compaction/reclaim.

-Deb

On Thu, Jun 11, 2015 at 5:16 PM, Chris Mason <clm@fb.com> wrote:

> networking is asking for 32KB, and the MM layer is doing what it can to
> provide it.  Are the gains from getting 32KB contig bigger than the cost
> of moving pages around if the MM has to actually go into compaction?
> Should we start disk IO to give back 32KB contig?
>
> I think we want to tell the MM to compact in the background and give
> networking 32KB if it happens to have it available.  If not, fall back
> to smaller allocations without doing anything expensive.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
