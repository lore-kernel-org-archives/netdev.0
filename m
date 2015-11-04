From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: isolate unbridged ports
Date: Thu, 5 Nov 2015 00:25:13 +0100
Message-ID: <20151104232513.GA8263@lunn.ch>
References: <1446675820-25608-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <563A8A05.6020401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <563A8A05.6020401@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port, u32 members)
> > +{
> > +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> > +	const u16 pvid = 4000 + ds->index * DSA_MAX_PORTS + port;
> > +	int err;
> > +
> > +	/* The port joined a bridge, so leave its reserved VLAN */
> > +	mutex_lock(&ps->smi_mutex);
> > +	err = _mv88e6xxx_port_vlan_del(ds, port, pvid);
> > +	if (!err)
> > +		err = _mv88e6xxx_port_pvid_set(ds, port, 0);
> 
> Does that mean that the following happens:
> 
> - bridge is created and port joins it
> - port is configured to be in pvid 0 while joining
> - port is then configured again by the bridge layer to be in whatever
> pvid the user has decided
> 
> The other question is, does that break isolation between multiple
> bridges on the same switch? Should we use the bridge ifindex here
> somehow as a pvid indication?

Hi Florian

The old code which got changed when VLAN support was added used some
property from the bridge to handle multiple bridges.

But that is probably a different bug to the one being fixed here.
This is all about using ports individually.

     Andrew
