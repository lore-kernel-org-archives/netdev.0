From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: dummy as IMQ replacement
Date: Mon, 21 Mar 2005 22:08:28 +0000
Message-ID: <423F45DC.6090803@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>	 <1107174142.8021.121.camel@jzny.localdomain>	 <00c301c524b4$938cd240$6e69690a@RIMAS>	 <1110379135.1091.143.camel@jzny.localdomain>	 <1110416767.1111.76.camel@jzny.localdomain>	 <025501c52552$2dbf87c0$6e69690a@RIMAS>	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>	 <1111196668.1146.114.camel@jzny.localdomain> <423BFD9F.50401@dsl.pipex.com> <1111324805.1094.11.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Remus <rmocius@auste.elnet.lt>,
        netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111324805.1094.11.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Hi Andy,
> Apologies again - I wont be able to get access to my test machine until
> tuesday.
> 
> On Sat, 2005-03-19 at 05:23, Andy Furniss wrote:
> 
> 
>>$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
>>match u32 0 0 flowid 1:1 \
>>action ipt -j MARK --set-mark 1
>>
>>It still gives memory error with 1.3.1 , with 1.2.11 it parses OK but I 
>>get bogus stats - hit count is OK
>>
>>[root@amd /home/andy/Qos]# tc -s filter ls dev eth0 parent ffff:
>>
>>filter protocol ip pref 10 u32
>>filter protocol ip pref 10 u32 fh 800: ht divisor 1
>>filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 
>>flowid 1:1  (rule hit 12 success 12)
>>   match 00000000/00000000 at 0 (success 12 )
>>         action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
>>         target MARK set 0x1
>>         index 1 ref 1 bind 1 installed 251 sec expires 1 sec
>>         Action statistics:
>>         Sent 7630953 bytes 0 pkt
>>         rate 3146Kbit 1095565348pps
>>
> 
> 
> Ok, this seems to be a bug in the stats - I think it may have been
> introduced during the new kernel stats code updates.
> Ive cced Thomas who added that code, he may be able to figure it oput
> before i get back
> 
> 
>>If I try with the lines below added
>>
>>action egress redirect dev dummy0 or
>>action redirect dev dummy0
>>
>>I just get errors on whatever is after action - or memory errors with 1.3.1.
>>
>>Using tc iproute2-ss050112 + patch for these tests.
>>
> 
> 
> So if i have understood you correctly, with this version of tc and
> version of iproute2, you have no problems other than stats being messed
> up? i.e action ipt .. action mirred .. looks/works fine?

No, I haven't got anything to work with action mirred the stats was just 
using

$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action ipt -j MARK --set-mark 1

Andy.
