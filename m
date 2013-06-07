From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: NULL pointer dereference when loading the gre module (3.10.0-rc4)
Date: Fri, 7 Jun 2013 10:43:03 +0200
Message-ID: <20130607084303.GE15083@uio.no>
References: <20130606221656.GA11475@uio.no>
 <20130607030648.GA28618@home.goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130607030648.GA28618@home.goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 06, 2013 at 11:06:48PM -0400, Steven Rostedt wrote:
> Note the faulting address is 0xffffffffa0e52001, which is around the
> above address, be interesting to know what was at that location.

Aha, the plot thickens:

root      6095  0.0  0.0   6632   596 ?        D    Jun06   0:00 /sbin/modprobe -q -- net-pf-17

pannekake:/usr/src/linux-3.10-rc4> sudo cat /proc/6095/stack
[<ffffffff812bb04f>] register_pernet_subsys+0x18/0x39
[<ffffffffa0ffd089>] packet_init+0x32/0x44 [af_packet]
[<ffffffff81000263>] do_one_initcall+0x7b/0x10c
[<ffffffff8107e5db>] load_module+0x1b1f/0x1e19
[<ffffffff8107e969>] SyS_init_module+0x94/0xa1
[<ffffffff8138cf12>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

I have a tcpdump running almost all the time (from boot), for a variety of
reasons. And I think I have the BPF JIT on; possibly related.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
