From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Tue, 22 Mar 2005 01:15:46 +0000
Message-ID: <423F71C2.8040802@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>	 <1107174142.8021.121.camel@jzny.localdomain>	 <00c301c524b4$938cd240$6e69690a@RIMAS>	 <1110379135.1091.143.camel@jzny.localdomain>	 <1110416767.1111.76.camel@jzny.localdomain>	 <025501c52552$2dbf87c0$6e69690a@RIMAS>	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com> <1111444869.1072.51.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111444869.1072.51.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2005-03-21 at 16:50, Andy Furniss wrote:
> 
>>jamal wrote:

> 
> But what happens when you try without mirred? Lets debug that first.
> 
> The fact that mirred fails is very strange - shouldnt;
> [You could try something like  "action ok" instead of "action mirred .."
> and see if cascading of actions works ..]. Remus didnt seem to have this
> specific issue.

Using 2.6.11.5 with new dummy.c and p_kstats.

p_tcstats wouldn't apply to latest iproute2 so used patched 
iproute2-ss050112 + p_tcstats

With iptables 1.3.1 and tc with it's iptables.h and iptables_common.h 
all I can do is -

++ /usr/sbin/tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 
match u32 0 0 flowid 1:1 action ok action ok

6 packets transmitted, 6 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.337/0.566/1.630/0.476 ms
[root@amd /home/andy/Qos]# tc -s filter ls dev eth0 parent ffff:
filter protocol ip pref 10 u32
filter protocol ip pref 10 u32 fh 800: ht divisor 1
filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 
flowid 1:1  (rule hit 6 success 6)
   match 00000000/00000000 at 0 (success 6 )
         action order 1: gact action pass
          random type none pass val 0
          index 3 ref 1 bind 1 installed 115 sec used 3 sec
         Action statistics:
         Sent 504 bytes 6 pkt (dropped 0, overlimits 0 requeues 0)
         rate 0bit 0pps backlog 0b 0p requeues 0

         action order 2: gact action pass
          random type none pass val 0
          index 4 ref 1 bind 1 installed 115 sec used 115 sec
         Action statistics:
         Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
         rate 0bit 0pps backlog 0b 0p requeues 0

ipt MARK now fails though -

++ /usr/sbin/tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 
match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark 1 action ok
tablename: mangle hook: NF_IP_PRE_ROUTING
         target: MARK set 0x1  index 0
RTNETLINK answers: Invalid argument
We have an error talking to the kernel


If I build same tc with iptables 1.2.11 headers and use iptables 1.2.11 
the above works.

mirred still fails whatever I try.

Andy.
