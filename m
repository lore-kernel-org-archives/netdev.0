From: Patrick McHardy <kaber@trash.net>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Fri, 25 Mar 2005 20:01:18 +0100
Message-ID: <42445FFE.6040408@trash.net>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <423B7BCB.10400@dsl.pipex.com>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>	 <1111663947.1037.24.camel@jzny.localdomain>	 <1111665450.1037.27.camel@jzny.localdomain>	 <4242DFB5.9040802@dsl.pipex.com>	 <1111749220.1092.457.camel@jzny.localdomain>	 <1111754346.1092.480.camel@jzny.localdomain>  <42444A14.30
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Remus <rmocius@auste.elnet.lt>,
        netdev <netdev@oss.sgi.com>, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111775660.1092.571.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2005-03-25 at 12:27, Patrick McHardy wrote:
> 
>>What does ps -eo args,wchan show?
>
> It shows tc stuck on wait_for_packet; 
> 
> user space is stuck in recvmsg(). It seems to be waiting for an
> NLMSG_DONE to complete the transaction - but that never comes.
> 
> One thing i've verified so far is it has nothing to do with the module
> replay code. I am also doubting it has naything to do with locks in
> the kernel. Its also a possibility that something changed in the
> iproute2 causing this stuck waiting for NLMSG_DONE.

Could it be that it is simply not making any forward progress?
tcf_dump_walker() doesn't save the number of skipped entries, but
the last order dumped, so it could dump the same entries again
and again when they exceed the room in the skb.

Regards
Patrick
