From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Tue, 22 Mar 2005 21:09:44 +0000
Message-ID: <42408998.5000202@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>	 <1107174142.8021.121.camel@jzny.localdomain>	 <00c301c524b4$938cd240$6e69690a@RIMAS>	 <1110379135.1091.143.camel@jzny.localdomain>	 <1110416767.1111.76.camel@jzny.localdomain>	 <025501c52552$2dbf87c0$6e69690a@RIMAS>	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111462263.1109.6.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Andy,
> Thanks for all your efforts.
> I will be back on my regular setup by tommorow evening and should be
> able to hopefuly test this. I am going to try:
> 
> - latest iproute2 with 1.3.x ipt changes
> - i am just gonna jump to iptables 1.3.x - we are going to ignore 1.2.11
> and below 
> - kernel 2.6.11.5 patches with stats
> 
> Issues seen so far - the following dont work:
> 
> a) tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
> match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark
> [Actually did you test this?]

Not without the 1 - If I do I get

++ /usr/sbin/tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 
match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark
ipt: option `--set-mark' requires an argument
tablename: mangle hook: NF_IP_PRE_ROUTING
         target: MARK set 0x0  index 0
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

With the one -

++ /usr/sbin/tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 
match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark 1
tablename: mangle hook: NF_IP_PRE_ROUTING
         target: MARK set 0x1  index 0
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

> 
> b) above with mirred as the next action fails in user space

Yes -

++ /usr/sbin/tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 
match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark 1 action mirred 
egress redirect dev dummy0
tablename: mangle hook: NF_IP_PRE_ROUTING
         target: MARK set 0x1  index 0
bad action type mirred
Usage: ... gact <ACTION> [RAND] [INDEX]
Where: ACTION := reclassify | drop | continue | pass RAND := random 
<RANDTYPE> <ACTION> <VAL>RANDTYPE := netrand | determVAL : = value not 
exceeding 10000INDEX := index value used
bad action parsing
parse_action: bad value (5:mirred)!
Illegal "action"

I notice if I grep iproute for "bad action type" it's in m_gact.c which 
does not contain the word mirred to test at all.

> 
> c) a) with a simple "action ok" is also rejected by the kernel
> with "Invalid argument"

Yes.

> 
> Did i miss anything else?

Don't think so - I can get a and c to work with older iptables and headers.

Andy.
