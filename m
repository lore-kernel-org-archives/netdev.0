From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 22:15:24 +0100
Message-ID: <20050125211524.GH31837@postel.suug.ch>
References: <20050124164049.3b939791.davem@davemloft.net> <20050125014538.GB31837@postel.suug.ch> <20050125014838.GA16637@gondor.apana.org.au> <20050125020118.GC31837@postel.suug.ch> <20050124180354.63ae600d.davem@davemloft.net> <20050125022431.GD31837@postel.suug.ch> <20050124194328.20a106de.davem@davemloft.net> <20050125143319.GF31837@postel.suug.ch> <20050125203607.GG31837@postel.suug.ch> <41F6B090.6020602@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, david@davidcoulson.net, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>,
        "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050125125019.5ca32de1.davem@davemloft.net> <41F6B090.6020602@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Ben Greear <41F6B090.6020602@candelatech.com> 2005-01-25 12:48
> Thomas Graf wrote:
> >NETIF_F_IP_CSUM|NETIF_F_HW_CSUM:
> >  Assuming that the vlan accel code can always do the checksumming
> >  if the card can do it.
> 
> I am leery of assuming these things for all drivers and all chipsets.
> 
> Maybe the driver itself could tell vlan code what sorts of flags it
> can set?  That takes the guess-work out, and each driver can add
> the features support as it is verified to work.  If any particular
> hacks need to be used (ie, maybe chipset foo.rev-1a can't handle one
> particular thing), then the VLAN code doesn't have to care.
> 
> 	new_dev->features = real_dev->vlan_features;
> 
* David S. Miller <20050125125019.5ca32de1.davem@davemloft.net> 2005-01-25 12:50
> I bet there are cards that don't have VLAN hw assist yet
> can properly checksum such packets.  One example I am counting
> on to fit this property is the 3c59x.
> 
> This is why I'm suggesting some kind of inheritance indication
> explicitly from the real_dev driver.  Perhaps even something
> like:
> 
> 	unsigned int vlan_inherited_features;
> 
> in the netdev struct.

I thought about this too and actually implemented it but it means to
change all relevant drivers and the only feature that might be
driver specific is checksumming, given I didn't make any mistakes
while checking the drivers for pskb compatibility. Therefore I tried
to avoid it but it seems we can't get around it.

Any objections in inheriting SG|NO_CSUM|HIGH_DMA|FRAGLIST|TSO by
default or leave it to the driver as well?
