From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: page allocation failure
Date: Sat, 16 Oct 2004 22:48:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041016204848.GB21849@electric-eye.fr.zoreil.com>
References: <200410162004.17573.jkillius@arcor.de> <200410162134.22727.jkillius@arcor.de> <20041016195435.GA21317@electric-eye.fr.zoreil.com> <200410162212.14676.jkillius@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Killius <jkillius@arcor.de>
Content-Disposition: inline
In-Reply-To: <200410162212.14676.jkillius@arcor.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jan Killius <jkillius@arcor.de> :
> On Saturday 16 October 2004 21:54, you wrote:
> > Jan Killius <jkillius@arcor.de> :
[...]
> Here is the first error I have attached my bzipped System.map
> Oct 16 19:27:00 gate swapper: page allocation failure. order:3, mode:0x20
> Oct 16 19:27:00 gate [<c013131e>]
> Oct 16 19:27:00 gate [<c0131458>]
> Oct 16 19:27:00 gate [<c0134337>]
> Oct 16 19:27:00 gate [<c0134eaa>]
> Oct 16 19:27:00 gate [<c013510d>]
> Oct 16 19:27:00 gate [<c01354cc>]
> Oct 16 19:27:00 gate [<c01ff1c0>]

c01ff130 T skb_under_panic
c01ff180 T alloc_skb
c01ff270 t skb_drop_fraglist

> Oct 16 19:27:00 gate [<c022d975>]
> Oct 16 19:27:00 gate [<c022ddb2>]

c022d8d0 T tcp_set_skb_tso_segs
c022d920 t tcp_fragment
c022dc70 t __pskb_trim_head

[...]
> > Rate value and 'vmstat 1' for a few seconds during test would be
> > welcome.
>  1  0 131328  54876  15540  43616    0    0     0   132 33110  6424  0 93  7 0
>  1  0 131328  54812  15540  43616    0    0     0     0 35681 18766  2 90  8 0
>  1  0 131328  54428  15540  43616    0    0     0     0 35664 19280  0 91  9 0
>  1  0 131328  53340  15540  43616    0    0     0     0 35668 18263  1 91  8 0
>  1  0 131328  53404  15540  43616    0    0     0     0 35745 20324  2 90  8 0

- what is the current transfer rate and is it better/worse w/o TSO ?
- which cpu/disk system are there within the (?) 128Mo box ?

I am not sure there is much to do. Lower the cache ? Suggestions anyone ?

[...]
> > <finger in the wind>
> > Can you disable TSO and tell if the messages disappear ?
> > </finger in the wind>
> with TSO off there are no messages.
> >
> > > Now I have new errors:
> > > eth2: Rx buffers exhausted
> > > The system is still running and the network is functional too.
> >
> > You are running with NAPI enabled, right ?
> Yes.

The system would probably not have recovered from Rx buffers
exhaustion otherwise. :o)

> > Please, pretty please, keep the Cc: on netdev. It is archived and
> > googlable whereas my mailbox is not.
> sorry.

No problem.

--
Ueimor
