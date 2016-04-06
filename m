From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net: dsa: make the FDB add function return
 void
Date: Wed, 6 Apr 2016 14:54:21 +0200
Message-ID: <20160406125421.GF19409@lunn.ch>
References: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1459869875-23815-2-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20160405235119.GC19409@lunn.ch>
 <87egajxwb5.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87egajxwb5.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2016 at 11:14:54PM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >>  	mutex_lock(&ps->smi_mutex);
> >> -	ret = _mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state);
> >> +	if (_mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state))
> >> +		netdev_warn(ds->ports[port], "cannot load address\n");
> >
> > In the SF2 driver you use pr_err, but here netdev_warn. We probably
> > should be consistent if we error or warn. I would use netdev_error,
> > since if this fails we probably have a real hardware problem.
> 
> I used pr_err in the SF2 driver to be consistent with the rest of the
> code which only uses pr_err and pr_info.

O.K, good.
 
> I was thinking about adding ds_err and ds_port_err to print errors for
> ds->master_dev and ds->ports[port], but that might be overkill.

I'm also trying to kill off the use of ds within the mv88e6xxx driver.

> What do you think? Or local to the driver for the moment, like
> mvsw_err maybe?

I would keep it local. Also, for this sort of error, it does not need
to differentiate on port. It is a hardware access error, something is
wrong with the mdio bus/switch. So i would even put the message in the
very low level reg_read/reg_write functions, and no where else.

     Andrew
