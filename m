From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Fw: Re: [PATCH] (6/6) ipvs -- get rid of skb_linearize
Date: Tue, 23 Sep 2003 00:45:06 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030922145239.976AE2C244@lists.samba.org>
References: <20030920010526.7d9a3ff4.davem@redhat.com>
Cc: Julian Anastasov <ja@ssi.bg>, Stephen Hemminger <shemminger@osdl.org>,
        Wensong Zhang <wensong@linux-vs.org>, lvs-users@LinuxVirtualServer.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Sat, 20 Sep 2003 01:05:26 MST."
             <20030920010526.7d9a3ff4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030920010526.7d9a3ff4.davem@redhat.com> you write:
> 	We have another solution for this problem, may be it is
> better the following stuff to be included now. Rusty, Dave? Is
> someone willing to review this before inclusion?

Sure...

> http://www.ssi.bg/~ja/ipvs-2.6.0-test2/readme.txt

> - at least struct iphdr in first fragment, not shared
> 
> - ip_defrag is already called, so ip_send_check is still needed
> 
> - then we add all needed checks for read and write access and extending
> the first fragment

Alexey's advice was not to pull packets we don't modify, but use
skb_copy_bits, and use skb_ip_make_writable() where we do modify.
This means that you don't have to care about shared or cloned skbs, it
makes your intentions explicit, and it's more future-proof.

It's more invasive, but my experience with doing netfilter_ipv4 was
that it made things much neater when finished.  It helps to get rid of
lots of the temporary variables, too, I've found (too easy to forget
to update them).

Here's a patch series below which does this.  Compiled, not tested.
Please read and advise if you want to go this way:

http://www.kernel.org/pub/linux/kernel/people/rusty/patches/IPVS/ipvs_packet_app_pkt_return.patch.gz
http://www.kernel.org/pub/linux/kernel/people/rusty/patches/IPVS/ipvs_nonlinear_protocols.patch.gz
http://www.kernel.org/pub/linux/kernel/people/rusty/patches/IPVS/ipvs_nonlinear_scheduler.patch.gz
http://www.kernel.org/pub/linux/kernel/people/rusty/patches/IPVS/ipvs_nonlinear_apps.patch.gz
http://www.kernel.org/pub/linux/kernel/people/rusty/patches/IPVS/ipvs_nonlinear_ip_vs_core.patch.gz
http://www.kernel.org/pub/linux/kernel/people/rusty/patches/IPVS/ipvs_nonlinear_ip_vs_xmit.patch.gz

Thanks,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
