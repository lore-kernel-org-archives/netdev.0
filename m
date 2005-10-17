From: Reuben Farrelly <reuben-lkml@reub.net>
Subject: Re: 2.6.14-rc4-mm1
Date: Mon, 17 Oct 2005 19:19:31 +1300
Message-ID: <43534273.2050106@reub.net>
References: <fa.h4unqgj.l34e31@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751340AbVJQGTf@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <fa.h4unqgj.l34e31@ifi.uio.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 16/10/2005 10:42 p.m., Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.14-rc4/2.6.14-rc4-mm1/
> 
> - Lots of i2c, PCI and USB updates
> 
> - Large input layer update to convert it all to dynamic input_dev allocation
> 
> - Significant x86_64 updates
> 
> - MD updates
> 
> - Lots of core memory management scalability rework

Compiles and runs here, but noting these messages when ethernet link down:

Oct 17 18:49:40 tornado kernel: NEIGH: BUG, double timer add, state is 1
Oct 17 18:51:04 tornado last message repeated 3 times
Oct 17 18:52:05 tornado last message repeated 5 times
Oct 17 18:52:11 tornado last message repeated 2 times

net/core/neighbour.c has this:

static inline void neigh_add_timer(struct neighbour *n, unsigned long when)
{
         if (unlikely(mod_timer(&n->timer, when))) {
                 printk("NEIGH: BUG, double timer add, state is %x\n",
                        n->nud_state);
         }
}


Network guys?

reuben
