From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: IMQ again WAS(Re: iptables breakage WAS(Re: dummy	as	IMQ	replacement
Date: Mon, 28 Mar 2005 15:28:41 +0100
Message-ID: <42481499.1060103@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>	 <1111663947.1037.24.camel@jzny.localdomain>	 <1111665450.1037.27.camel@jzny.localdomain>	 <4242DFB5.9040802@dsl.pipex.com>	 <1111749220.1092.457.camel@jzny.localdomain>	 <42446DB2.9070809@dsl.pipex.com>	 <1111781443.1092.631.camel@jzny.localdomain>	 <4244802C.7020202@dsl.pipex.com>	 <1111788760.1090.712.camel@jzny.localdomain>	 <42470AF9.8050402@dsl.pipex.com>  <424808F7.50101@dsl.pipex.com>	 <1112017546.1089.1048.camel@jzny.localdomain>	 <1112018231.1090.1051.camel@jzny.localdomain>	 <42481
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev <netdev@oss.sgi.com>,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112019614.1090.1068.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2005-03-28 at 09:12, Andy Furniss wrote:
> 
> 
>>Hmm - it works on ingress and all I really wanted to do was
>>
> 
> 
> Yes but you installed ingress qdisc ;->
> 
>>tc filter add dev eth0 parent 0: protocol ip prio 10 u32 match ip src 
>>0/0 action mirred egress redirect dev dummy0
>>
> 
> 
> Likewise you need to install egress qdisc
> 
> Alexey did warn about making default qdisc visible - that people would
> come back and ask for more ;->
> If we are going to allow this then i think we should make ingress also
> on by default (so the install before use doesnt apply there either).
> 
> cheers,
> jamal
> 
> 

Still having probs - rebooted and tried -

[root@amd /home/andy/Qos]# tc qdisc add dev eth0 root pfifo

[root@amd /home/andy/Qos]# tc -s qdisc ls dev eth0
qdisc pfifo 8001: limit 1000p
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0

[root@amd /home/andy/Qos]# tc filter add dev eth0 parent 8001: protocol 
ip prio 10 u32 match ip src 192.168.200.200/32 flowid 1:2 action police 
rate 100kbit burst 90k drop
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

[root@amd /home/andy/Qos]# tc filter add dev eth0 parent 1: protocol ip 
prio 10 u32 match ip src 192.168.200.200/32 flowid 1:2 action police 
rate 100kbit burst 90k drop
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

[root@amd /home/andy/Qos]# tc filter add dev eth0 parent 0x8001: 
protocol ip prio 10 u32 match ip src 192.168.200.200/32 flowid 1:2 
action police rate 100kbit burst 90k drop
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

[root@amd /home/andy/Qos]# tc qdisc del dev eth0 root pfifo

[root@amd /home/andy/Qos]# tc qdisc add dev eth0 root handle 1:0 pfifo

[root@amd /home/andy/Qos]# tc -s qdisc ls dev eth0
qdisc pfifo 1: limit 1000p
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0

[root@amd /home/andy/Qos]# tc filter add dev eth0 parent 1: protocol ip 
prio 10 u32 match ip src 192.168.200.200/32 flowid 1:2 action police 
rate 100kbit burst 90k drop
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Andy.
