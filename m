From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 15:33:19 +0100
Message-ID: <20050125143319.GF31837@postel.suug.ch>
References: <20050124225423.GA15405@gondor.apana.org.au> <20050124234515.GA31837@postel.suug.ch> <20050125000759.GA15883@gondor.apana.org.au> <20050124164049.3b939791.davem@davemloft.net> <20050125014538.GB31837@postel.suug.ch> <20050125014838.GA16637@gondor.apana.org.au> <20050125020118.GC31837@postel.suug.ch> <20050124180354.63ae600d.davem@davemloft.net> <20050125022431.GD31837@postel.suug.ch> <20050124194328.20a106de.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, david@davidcoulson.net, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050124194328.20a106de.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050124194328.20a106de.davem@davemloft.net> 2005-01-24 19:43
> On Tue, 25 Jan 2005 03:24:31 +0100
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > This of course explains it, didn't think of that. I thought it would
> > inherit the checksumming features.
> 
> It should, but only in very limited cases.
> 
> For example, it probably only works properly when HW vlan assist
> is being used on TX.  It's likely that the chips which don't support
> VLAN assist also can't handle VLAN headers in their TX checksumming
> engine.

I agreed, but those who have vlan accel are likely to be able to
also do the checksumming. 

> Because it is very chip dependant whether this works or not in
> any case, we should probably create a special features flag for
> this.  Something like NETIF_F_VLAN_INHERIT_FEATURES.

Can't we just use NETIF_F_HW_VLAN_TX for this and inherit
NETIF_F_HW_CSUM | NETIF_F_IP_CSUM if it is set? I don't have any
specs at hand though.
