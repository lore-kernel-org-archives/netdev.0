From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Kernel BUG: Qos seg. fault
Date: Mon, 24 May 2004 14:25:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524212553.52149.qmail@web80507.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jaume Catarineu <jaume.catarineu@upf.edu>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal wrote:

> On Mon, 2004-05-24 at 16:14, Dmitry Torokhov wrote:
> 
> > prio qdisc can have several child qdiscs attached to it so I can see
> > why it supports filters. But what is the point of TBF having filter
> > attached? TBF either drops packet or passes it to its only child,
> > there isn't anything to filter. Or am I missing something?
> 
> If the TBF is pretending even in the slightest to be a classful qdisc
> which i believe it does in the latest reincarnation i think it would be
> a good idea to maintain the semantics of classful qdiscs - maintain a
> filter list.
> What do you mean it will only pass it to its child? Why were you trying
> to attach a filter to it then? Sorry, I havent paid attention to how it
> was supposed to be used.

The only reason TBF has a class is that within current framework 
net/sched framework child qdisc can only be attached to a class.
So TBF defines a class (there is only one per TBF qdisc, it's
created automatically and can not be changed) much like sch_prio
does. The difference is that sch_prio can have up to TCQ_PRIO_BANDS
children so implementing filters for sch_prio makes sense. TBF has
one and only one child qdisc. It starts with noop_qdisc from
sch_generic and later user can change to to something else, like
original poster did.

Since TBF has only one child no matter what I contend that 
implementing filters for TBF does not make sense, filters should
be attached either to TBF's child ot to TBF's parent but not to
TBF itself.

Dmitry
