From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 15:45:37 -0500
Message-ID: <1111783537.1088.659.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>
	 <1111410890.1092.195.camel@jzny.localdomain>
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
	 <1111749220.1092.457.camel@jzny.localdomain
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
In-Reply-To: <4244720C.1040907@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 15:18, Patrick McHardy wrote:

> Before this the ipt action needs to make sure the packets are in valid
> state from the view of conntrack/ip_tables. Right now it doesn't even
> check if its IP. 

In regards to ipt:
This is true and the checking needs to be done. 
At the moment it is expected the user will only direct IP packets at
ipt. Note, however - desire is not to just stick to iptables
but rather also accept arp packets and use targets arptables has etc. 
In such cases it will be important that checks are made.
Even in this case though -there will be target which probably wont care
if i gave them a decnet packet or IP - example mark. Is this correct? I
can understand when headers are to be mucked with.

in regards to tracking:
We will have actions that will do all those validations - but the choice
will be upto the users policy. Will tracking have issues if i passed it
a packet that didnt have the correct checksum?

> Both assume the length checks in ip_rcv() have been
> performed, it actually creates security problems in a few places if
> they haven't - length calculations can underflow and bad things will
> happen.
> 

I havent really stared at the contrack code - If i ask it to track for
me though, would it have issues?
Recall that the packets at the two tc spots (ingress/egress) already
have their skb pointers in the right spots.

cheers,
jamal
