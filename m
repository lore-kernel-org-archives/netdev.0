From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference when loading the gre module
 (3.10.0-rc4)
Date: Fri, 07 Jun 2013 06:40:41 -0700
Message-ID: <1370612441.24311.411.camel@edumazet-glaptop>
References: <20130606221656.GA11475@uio.no>
	 <20130607030648.GA28618@home.goodmis.org> <20130607085421.GF15083@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Pravin B Shelar <pshelar@nicira.com>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130607085421.GF15083@uio.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-07 at 10:54 +0200, Steinar H. Gunderson wrote:
> On Thu, Jun 06, 2013 at 11:06:48PM -0400, Steven Rostedt wrote:
> > Note the faulting address is 0xffffffffa0e52001, which is around the
> > above address, be interesting to know what was at that location.
> 
> Doh, I looked at the wrong place in kallsyms:
> 
> ffffffffa0e52000 u ip_tunnel_init_net   [ip_gre]
> ffffffffa0e55000 t gre_err      [gre]
> ffffffffa0e5503d t gre_gso_send_check   [gre]
> ffffffffa0e55053 t gre_rcv      [gre]
> 
> So it's really ip_tunnel_init_net+1.
> 
> /* Steinar */

" u " for ip_tunnel_init_net ?

Looks like someone forgot taking refcounts on a module ...

CC Pravin B Shelar, as this probably comes from commit
c54419321455631079c7d6e60bc732dd0c5914c5
("GRE: Refactor GRE tunneling code.")
