From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [RFC] ethtool semantics
Date: Mon, 14 Jun 2004 21:42:56 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040614194256.GC22012@k3.hellgate.ch>
References: <20040607212804.GA17012@k3.hellgate.ch> <20040607145723.41da5783.davem@redhat.com> <20040608210809.GA10542@k3.hellgate.ch> <40C77C70.5070409@tmr.com> <20040609213850.GA17243@k3.hellgate.ch> <20040609151246.1c28c4d9.davem@redhat.com> <Pine.LNX.4.58.0406141458270.16762@fcat> <20040614170138.GA32594@hockin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Herbert <marc.herbert@free.fr>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263824AbUFNTvY@vger.kernel.org>
To: Tim Hockin <thockin@hockin.org>
Content-Disposition: inline
In-Reply-To: <20040614170138.GA32594@hockin.org>
List-Id: netdev.vger.kernel.org

On Mon, 14 Jun 2004 10:01:38 -0700, Tim Hockin wrote:
> On Mon, Jun 14, 2004 at 03:11:15PM +0200, Marc Herbert wrote:
> > > That is absolutely the correct thing to do, module parameters for
> > > link settings are %100 deprecated, people need to use ethtool for
> > > everything.
> > 
> > This is precisely the reason why I am concerned about having "rich"
> > ethtool semantics. A unified, standard interface is great,... as long
> > it does not leave behind some features, like setting the advertised
> > values in autoneg. As a user of these features, I hope driver
> > developers will NOT remove those module_param features that cannot
> > migrated to ethtool.
> 
> So propose a sane semantic that handles all three cases:
> * autoneg on
> * autoneg off
> * autoneg on but limited

My first thought was if a command contains speed/duplex settings
and autoneg is on, manipulate advertised value; if autoneg is off,
force mode. That's not possible due to the way ethtool interacts with
the kernel: It doesn't request a change in a specific field. Instead,
ethtool reads all fields, flips the values it wants to have changed,
then issues a set request for everything (speed, duplex, autoneg,
etc.). In other words: speed/duplex fields are set for every call.

One way out would be to have an explicit third option, say autoneg mask.

That would give:
autoneg on + speed/duplex -> error (only userspace/ethtool can do this!)
autoneg off + speed/duplex -> force mode (driver)
autoneg mask + speed/duplex -> change advertised value (driver)

Many drivers would only support one of these two methods (force mode
presumably), so we'd have to either throw an error if an unsupported
method is requested, or print a notice and use the supported method to
force the requested mode.

Roger
