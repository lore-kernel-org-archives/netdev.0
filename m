From: jamal <hadi@cyberus.ca>
Subject: Re: IMQ again WAS(Re: iptables breakage WAS(Re: dummy
	as	IMQ	replacement
Date: 28 Mar 2005 09:08:28 -0500
Message-ID: <1112018908.1090.1064.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
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
	 <1111781443.1092.631.camel@jzny.localdomain>
	 <4244802C.7020202@dsl.pipex.com>
	 <1111788760.1090.712.camel@jzny.localdomain>
	 <42470AF9.8050402@dsl.pipex.com>  <42
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev <netdev@oss.sgi.com>,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <42480CC4.3040305@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-28 at 08:55, Andy Furniss wrote:

> > Dont see why this shouldnt work. You are saying it works with
> > non-aliased interface addreses?
> 
> No it doesn't work at all.
> 
> I noticed default qdisc has handle 0:
> 
> #tc -s qdisc ls dev eth0
> qdisc pfifo_fast 0: bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>   Sent 13024 bytes 95 pkt (dropped 0, overlimits 0 requeues 0)
>   rate 0bit 0pps backlog 0b 0p requeues 0
> 
> but using parent 0: instead of 1: still fails.
> 

Aha! You need to create root qdisc 1: for it to work. 
pfifo_fast is essentially just basic prio and it was supposed to be
hidden so user doesnt know it exists (blame me for why it is visible).
So try installing prio and see if it still fails.

cheers,
jamal
