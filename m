From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Patch v2] netpoll: warn when there are spaces in parameters
Date: Mon, 22 Mar 2010 23:45:20 -0500
Message-ID: <1269319520.3552.76.camel@calx>
References: <20100322090341.5289.10770.sendpatchset@localhost.localdomain>
	 <1269296535.3552.10.camel@calx>  <4BA81D18.40509@redhat.com>
	 <1269318256.3552.49.camel@calx>  <4BA844E6.6060602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	elendil@planet.nl, David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BA844E6.6060602@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-03-23 at 12:34 +0800, Cong Wang wrote:
> Matt Mackall wrote:
> > On Tue, 2010-03-23 at 09:44 +0800, Cong Wang wrote:
> >> Matt Mackall wrote:
> >>> On Mon, 2010-03-22 at 04:59 -0400, Amerigo Wang wrote:
> >>>> +			printk(KERN_INFO "%s: warning: whitespace"
> >>>> +					"is not allowed\n", np->name);
> >>> Is it a warning or is it info? If it's a warning, then we probably need
> >>> to add "netpoll" or whatever to the message so that people who've got a
> >>> warning-level threshold will know what it's about.
> >>>
> >> If you mean KERN_INFO, yeah, I want to keep it in the same level
> >> as other messages around.
> > 
> > I should probably be more direct: I think that's the wrong thing to do.
> > It IS a warning (it even says so!) telling users that something probably
> > won't work and why and they might miss it if the severity is INFO and
> > then come and ask us why things aren't working. So use KERN_WARN,
> > please.
> 
> 
> They _are_ working, 0 will be assigned by default.

If this patch has any point at all other than filling the logs, it
should be WARN.

> > 
> > The other messages are INFO because when things are working, they're not
> > interesting.
> > 
> 
> They are not all working, take this as an example:
> 
>          printk(KERN_INFO "%s: couldn't parse config at %s!\n",
>                 np->name, cur);

Yeah, that's obviously wrong too. Let's not add more wrongness just for
consistency's sake.

-- 
http://selenic.com : development and support for Mercurial and Linux
