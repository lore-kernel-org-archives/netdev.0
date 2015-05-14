From: Willem de Bruijn <willemb@google.com>
Subject: Re: linux-next: build warnings after merge of the net-next tree
Date: Thu, 14 May 2015 10:47:54 -0400
Message-ID: <CA+FuTSc9N6bwz5MOt51OuYsVpbqY4BrHM-anhh7aee=ZcQ47aw@mail.gmail.com>
References: <20150514171206.2fe660ec@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150514171206.2fe660ec@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 14, 2015 at 3:12 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (sparc64 defconfig)
> produced these warnings:
>
> In file included from arch/sparc/include/asm/cmpxchg.h:4:0,
>                  from arch/sparc/include/asm/atomic_64.h:11,
>                  from arch/sparc/include/asm/atomic.h:4,
>                  from include/linux/atomic.h:4,
>                  from include/linux/spinlock.h:416,
>                  from include/linux/mmzone.h:7,
>                  from include/linux/gfp.h:5,
>                  from include/linux/mm.h:9,
>                  from net/packet/af_packet.c:56:
> net/packet/af_packet.c: In function 'packet_rcv_has_room':
> arch/sparc/include/asm/cmpxchg_64.h:43:22: warning: value computed is not used [-Wunused-value]
>  #define xchg(ptr,x) ((__typeof__(*(ptr)))__xchg((unsigned long)(x),(ptr),sizeof(*(ptr))))
>                       ^
> net/packet/af_packet.c:1314:3: note: in expansion of macro 'xchg'
>    xchg(&po->pressure, !has_room);
>    ^
> net/packet/af_packet.c: In function 'packet_poll':
> arch/sparc/include/asm/cmpxchg_64.h:43:22: warning: value computed is not used [-Wunused-value]
>  #define xchg(ptr,x) ((__typeof__(*(ptr)))__xchg((unsigned long)(x),(ptr),sizeof(*(ptr))))
>                       ^
> net/packet/af_packet.c:3817:3: note: in expansion of macro 'xchg'
>    xchg(&po->pressure, 0);
>    ^
>
> Introduced by commit 2ccdbaa6d55b ("packet: rollover lock contention
> avoidance").

I just sent http://patchwork.ozlabs.org/patch/472362/ to resolve
these. Thanks for the report.
