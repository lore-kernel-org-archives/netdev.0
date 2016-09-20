From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: handle multiple ports in
 ATU
Date: Tue, 20 Sep 2016 02:32:36 +0200
Message-ID: <20160920003236.GD6323@lunn.ch>
References: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com>
 <20160920001914.GB6323@lunn.ch>
 <87oa3jo1l7.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87oa3jo1l7.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2016 at 08:29:40PM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > Hi Vivien
> >
> >> +	do {
> >> +		err = _mv88e6xxx_atu_getnext(chip, fid, &next);
> >> +		if (err)
> >> +			return err;
> >> +
> >> +		if (next.state == GLOBAL_ATU_DATA_STATE_UNUSED)
> >> +			break;
> >> +
> >> +		if (ether_addr_equal(next.mac, addr)) {
> >> +			*entry = next;
> >> +			return 0;
> >> +		}
> >> +	} while (!is_broadcast_ether_addr(next.mac));
> >
> > This is correct, but i wonder how well it scales? When we have a lot
> > of entries in the ATU, this is going to take time. At some point in
> > the future, we might want to keep a shadow copy of static entries of
> > the ATU in RAM. We then don't need to search for them.
> 
> There won't be any issue about time here, because we are searching a
> precise FID.

Ah, i didn't realise you can do that. However, it makes sense, the
hardware needs to do it all the time when it receives a frame.

	 Andrew
