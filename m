From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 23 Mar 2005 14:45:12 -0500
Message-ID: <1111607112.1072.48.camel@jzny.localdomain>
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
	 <1111444869.1072.51.camel@jzny.localdomain>
	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>
	 <42408998.5000202@dsl.pipex.com>
	 <1111550254.1089.21.camel@jzny.localdomain>
	 <4241C478.5030309@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <4241C478.5030309@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-23 at 14:33, Andy Furniss wrote:

> > bantu:~# tc -s filter ls dev eth0 parent ffff:
> 
> didn't get bash prompt back after doing this till <ctrl><c> but works 
> and looks OK. 

Needs investigation. Lets defer for now, and see if it continues to
happen

> Works if I direct to dummy0 aswell :-)
> 

Good - hopefully we can now get to where you started ;-> 
I will send the kernel patch to Dave later.

> The thing that still fails is trying to use MARK - but I guess that's 
> not to do with mirred as I don't get any mention of it anymore.
> 


For me all targets are compiled into the kernel; I didnt try with
modules. If you have any modules try to compile in and see what happens.
If it works it could spell trouble perhaps with some of the module
replay code added recently.

> [root@amd /home/andy/Qos]# tc qdisc del dev eth0 ingress
> RTNETLINK answers: No such file or directory
> [root@amd /home/andy/Qos]# tc qdisc add dev eth0 ingress
> [root@amd /home/andy/Qos]# tc filter add dev eth0 parent ffff: protocol 
> ip prio 6 \
>  > u32 match ip src 10.0.2.24/32 flowid 1:16 \
>  > action ipt -j MARK --set-mark 1
> tablename: mangle hook: NF_IP_PRE_ROUTING
>          target: MARK set 0x1  index 0
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
> 

Ok, try the module thing; actually try to modprobe mark target first and
see if that works as well.

> I get exactly the same error if I also add action mirred egress redirect 
> dev lo - before I would get different.
> 

Didnt follow - still related to ipt?

cheers,
jamal
