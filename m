From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: NULL pointer dereference when loading the gre module
 (3.10.0-rc4)
Date: Fri, 07 Jun 2013 14:44:19 -0400
Message-ID: <1370630659.9844.89.camel@gandalf.local.home>
References: <20130606221656.GA11475@uio.no>
	 <20130607030648.GA28618@home.goodmis.org> <20130607085421.GF15083@uio.no>
	 <1370612441.24311.411.camel@edumazet-glaptop>
	 <1370618100.9844.73.camel@gandalf.local.home>
	 <20130607154634.GA7529@uio.no>
	 <1370621543.9844.78.camel@gandalf.local.home>
	 <20130607175233.GA20230@uio.no>
	 <1370629568.9844.87.camel@gandalf.local.home>
	 <20130607183438.GA23064@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Pravin B Shelar <pshelar@nicira.com>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130607183438.GA23064@uio.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-07 at 20:34 +0200, Steinar H. Gunderson wrote:
> On Fri, Jun 07, 2013 at 02:26:08PM -0400, Steven Rostedt wrote:
> > On Fri, 2013-06-07 at 19:52 +0200, Steinar H. Gunderson wrote:
> > Ah, that's because of this: module_init(ipgre_init);  Where it makes it
> > into:
> > 
> > 00000000 <init_module>:
> >    0:   55                      push   %ebp
> >    1:   89 e5                   mov    %esp,%ebp
> >    3:   53                      push   %ebx
> >    4:   83 ec 08                sub    $0x8,%esp
> >    7:   c7 04 24 00 00 00 00    movl   $0x0,(%esp)
> >                         a: R_386_32     .rodata.str1.4
> > 
> > We can use ipgre_tap_init_net, and the offset of 0xb032 (45106) as that
> > was 0xffffffffa0e5d034 - 0xffffffffa0e52002. Do you have CONFIG_NET_NS
> > set?
> 
> ipgre_tap_init_net is 000000000000001a, but there's no way I can subtract
> 0xb053 from that? Sorry, I'm confused. :-)

OK, then its most likely in another module (likely the ip_tunnel.ko).

Do know if you have CONFIG_NET_NS set in your .config?

> 
> > You can also cat /proc/modules. It gives you where the modules are
> > located.
> 
> I've booted back to 3.9.x already; I couldn't live with a crashing kernel like
> that. Unfortunately it's not that easy for me to reboot this machine all the
> time either. :-/

OK, if you get time, this may be a candidate to do a git bisect with.

Thanks,

-- Steve
