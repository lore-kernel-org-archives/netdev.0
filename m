From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 13:34:20 -0500
Message-ID: <1111775660.1092.571.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
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
	 <1
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
In-Reply-To: <42444A14.3090809@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 12:27, Patrick McHardy wrote:

> What does ps -eo args,wchan show?
> 

It shows tc stuck on wait_for_packet; dump is:

------
tc            S C06493A0     0 20153  20074                     (NOTLB)
c3e4fc1c 00000086 c4ea8d70 c06493a0 000005b4 00000000 00000000 00000000 
       00000000 00000000 00000000 00022e09 b5edbac0 000f48bb c4ea8d70
c4ea8ed8 
       00000000 7fffffff c3e4fca0 c3e4fc78 c04b28d4 c015a52d cffebc80
c3e4fc44 
Call Trace:
 [<c04b28d4>] schedule_timeout+0xd4/0xe0
 [<c03ae4f0>] wait_for_packet+0xb0/0x110
 [<c03ae6a3>] skb_recv_datagram+0x153/0x220
 [<c03eef68>] netlink_recvmsg+0x58/0x210
 [<c03a70ac>] sock_recvmsg+0xcc/0xf0
 [<c03a8c9b>] sys_recvmsg+0x13b/0x200
 [<c03a8f8d>] sys_socketcall+0x22d/0x240
 [<c0103c0d>] sysenter_past_esp+0x52/0x75
------

user space is stuck in recvmsg(). It seems to be waiting for an
NLMSG_DONE to complete the transaction - but that never comes.

One thing i've verified so far is it has nothing to do with the module
replay code. I am also doubting it has naything to do with locks in
the kernel. Its also a possibility that something changed in the
iproute2 causing this stuck waiting for NLMSG_DONE.

cheers,
jamal
