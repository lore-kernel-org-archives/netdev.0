From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 21 Mar 2005 17:41:09 -0500
Message-ID: <1111444869.1072.51.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>
	 <1111410890.1092.195.camel@jzny.localdomain>
	 <423F41AD.3010902@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <423F41AD.3010902@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-21 at 16:50, Andy Furniss wrote:
> jamal wrote:

> > To test the theory copy iptables.h and iptables_common.h from
> > iptables-1.3.1/include into iproute2/include with the latest iproute2
> > and recompile. Make sure m_ipt.c is recompiled - you may have to do a 
> > make clean in iproute2/tc/
> 
> I haven't done a new kernel with stats patched yet. 

Thanks for atching that btw - it was tricky; i have a strong feeling it
was resolved by patch i sent.

> Using iptables 1.3.1 
> and iproute2-ss050314 with iptables headers I now get below instead of 
> memory error.
> 
> ++ /usr/sbin/tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 
> match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark 1 action mirred 
> egress redirect dev dummy0
> tablename: mangle hook: NF_IP_PRE_ROUTING
>          target: MARK set 0x1  index 0
> bad action type mirred
> Usage: ... gact <ACTION> [RAND] [INDEX]
> Where: ACTION := reclassify | drop | continue | pass RAND := random 
> <RANDTYPE> <ACTION> <VAL>RANDTYPE := netrand | determVAL : = value not 
> exceeding 10000INDEX := index value used
> bad action parsing
> parse_action: bad value (5:mirred)!
> Illegal "action"
> 

But what happens when you try without mirred? Lets debug that first.

The fact that mirred fails is very strange - shouldnt;
[You could try something like  "action ok" instead of "action mirred .."
and see if cascading of actions works ..]. Remus didnt seem to have this
specific issue.

> I will try with new kernel later tonight.
> 
> > 
> > I should be able to validate all this stuff starting tommorow evening.
> > Also I have a feeling if you make this change, things will not work for
> > iptables <=1.2.9/10/11. Can you verify that?
> >
> 
> Yes it segfaults with iptables v1.2.11


So the changes that happened on iptables are neither forward nor
backward compatible. 
I am begining to question the wisdom of putting the header files
in iproute2. We may have to make a call and say we are going to work
only on iptables >= 1.3.0 - would this make sense?

cheers,
jamal
