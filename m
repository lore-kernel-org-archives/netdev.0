From: devik <devik@cdi.cz>
Subject: Re: [2.6.0-test9] QoS HTB crash...
Date: Fri, 31 Oct 2003 08:40:06 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0310310839100.11221-100000@devix>
References: <20031030130859.605f856d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <daniel.blueman@gmx.net>, <netdev@oss.sgi.com>,
        <linux-net@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031030130859.605f856d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hmm - I have to look at 2.6's definition of rb_next. It
might be the case ! I'll check it.

Thanks, devik

On Thu, 30 Oct 2003, David S. Miller wrote:

> On Thu, 30 Oct 2003 20:50:16 +0100 (CET)
> devik <devik@cdi.cz> wrote:
>
> > thanks for the report. I know that there is an issue regarding
> > HTB in 2.6.x. Please send me net/sched/sch_htb.o,
> > net/sched/sch_htb.c (just to be sure) and be sure that you
> > build the kernel with debugging symbols (see debugging section
> > of menuconfig/xconfig).
>
> I think the problem is the changes that were made
> in 2.5.x to htb_next_rb_node().  It used to be:
>
> static void htb_next_rb_node(rb_node_t **n)
> {
>         rb_node_t *p;
>         if ((*n)->rb_right) {
>                 /* child at right. use it or its leftmost ancestor */
>                 *n = (*n)->rb_right;
>                 while ((*n)->rb_left)
>                         *n = (*n)->rb_left;
>                 return;
>         }
>         while ((p = (*n)->rb_parent) != NULL) {
>                 /* if we've arrived from left child then we have next node */
>                 if (p->rb_left == *n) break;
>                 *n = p;
>         }
>         *n = p;
> }
>
> But it was changed into:
>
> static void htb_next_rb_node(struct rb_node **n)
> {
>         *n = rb_next(*n);
> }
>
> This is wrong, the new code has much different side effects
> than the original code.
>
> This looks like the problem, devik what do you think?
>
>
