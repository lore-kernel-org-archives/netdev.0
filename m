From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 16:57:04 -0500
Message-ID: <1111787824.1088.699.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <423B7BCB.10400@dsl.pipex.com> <1111410890.1092.195.camel@jzny.localdomain>
	 <423F41AD.3010902@dsl.pipex.com>
	 <1111444869.1072.51.camel@jzny.localdomain>
	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>
	 <42408998.5000202@dsl.pipex.com>
	 <1111550254.1089.21.camel@jzny.localdomain>
	 <4241C478.5030309@dsl.pipex.com>
	 <1111607112.1072.48.camel@jzny.localdomain>
	 <4241D764.2030306@dsl.pipex.com>
	 <1111612042.1072.53.camel@jzny.localdomain>
	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>
	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>
	 <1111663947.1037.24.camel@jzny.localdomain>
	 <1111665450.1037.27.camel@jzny.localdomain>
	 <4242DFB5.9040802@dsl.pipex.com>
	 <1111749220.1092.457.camel@jzny.localdomain>
	 <42446DB2.9070809@dsl.pipex.com>
	 <111178
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Remus <rmocius@auste.elnet.lt>,
        netdev <netdev@oss.sgi.com>, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42447E3D.5060409@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 16:10, Patrick McHardy wrote:

> No, it might (TCP) simply ignore them. NAT usually does incremental
> checksumming, except for ICMP errors. As for validation - I think we
> have two things, necessary validations, these can't be optional,
> and useless validations, since they are not necessary :) TCP checksum
> for example would be useless, since everything in iptables that cares
> about it needs to verify it itself anyway.
> 

This is very useful info.

> >>Both assume the length checks in ip_rcv() have been
> >>performed, it actually creates security problems in a few places if
> >>they haven't - length calculations can underflow and bad things will
> >>happen.
> > 
> > I havent really stared at the contrack code - If i ask it to track for
> > me though, would it have issues?
> > Recall that the packets at the two tc spots (ingress/egress) already
> > have their skb pointers in the right spots.
> 
> It will try to track. The problematic spots are length calculations,
> it is assumed that skb->len == iph->ihl*4.
> 

Those kind of things may be fine actually but not the checks.
The classifier depends on some of them being correct i.e
you can be assured  the ip header will be at skb->nh.iph when we pass
the packet
There is theory that ip_rcv() kind of check in any case belongs to some
action attached to a netdevice owning a table that contains IP addresses
for that netdevice ;-> This would really ease management of per device
IP addresses - maybe someday ;->.

cheers,
jamal
