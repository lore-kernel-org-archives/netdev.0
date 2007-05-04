From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH][SOCK]: shrink struct sock
Date: Fri, 4 May 2007 14:24:09 +0200
Message-ID: <20070504142409.f8fef9f7.dada1@cosmosbay.com>
References: <20070504041101.GA27519@ghostprotocols.net>
	<463ACE47.6080807@cosmosbay.com>
	<39e6f6c70705040424w77462efemfd0a2857bbecf15c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:57722 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754516AbXEDMYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 08:24:11 -0400
In-Reply-To: <39e6f6c70705040424w77462efemfd0a2857bbecf15c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 May 2007 08:24:34 -0300
"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net> wrote:

> On 5/4/07, Eric Dumazet <dada1@cosmosbay.com> wrote:
> > Hum, maybe not enough tea this morning, but I always thought spinlock_t size
> > was 4 bytes....
> 
> Well, unfolding sk_buff_head to see the details:
> 
> [acme@mica linux-2.6]$ pahole --expand_types -C sk_buff_head net/core/sock.o
> /* <9a61> /home/acme/git/linux-2.6/include/linux/skbuff.h:111 */
> struct sk_buff_head {
>         struct sk_buff *           next;              /*     0     8 */
>         struct sk_buff *           prev;              /*     8     8 */
>         /* typedef __u32 */ unsigned int qlen;        /*    16     4 */
>         /* typedef spinlock_t */ struct {
>                 /* typedef raw_spinlock_t */ struct {
>                         unsigned int slock;           /*    20     4 */
>                 } raw_lock; /*    20     4 */
>                 unsigned int       break_lock;        /*    24     4 */
>         } lock; /*    20     8 */
> }; /* size: 32, cachelines: 1 */
>    /* padding: 4 */
>    /* last cacheline: 32 bytes */
> 
> #if defined(CONFIG_PREEMPT) && defined(CONFIG_SMP)
>         unsigned int break_lock;
> #endif
> 
> Disabling CONFIG_PREEMPT makes you regain your confidence in the
> quality of your tea:

PREEMPT ? what is this ? Is it suitable for my machines with hundred of thousands of sockets ? :)

I hope you dont want to shrink struct sock for desktop users :)

BTW, your pahole tool is cool :)

