From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: IMQ again WAS(Re: iptables breakage WAS(Re: dummy as IMQ	replacement
Date: Fri, 25 Mar 2005 23:26:29 +0000
Message-ID: <42449E25.1060008@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>	 <1111663947.1037.24.camel@jzny.localdomain>	 <1111665450.1037.27.camel@jzny.localdomain>	 <4242DFB5.9040802@dsl.pipex.com>	 <1111749220.1092.457.camel@jzny.localdomain>	 <42446DB2.9070809@dsl.pipex.com>	 <1111781443.1092.631.camel@jzny.localdomain>	 <4244802C.
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev <netdev@oss.sgi.com>,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111788760.1090.712.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Changed subject to whats being discused ;->
> 
> On Fri, 2005-03-25 at 16:18, Andy Furniss wrote:
> 
>>jamal wrote:
> 
> [..]
> 
>>OK I would need that to recreate what I do now with IMQ hooked after 
>>deNAT so I can see local addresses and use connbytes in prerouting 
>>mangle (though that's on my 2.4 I can't get connbytes to work with 
>>latest netfilter yet anyway)
>>
> 
> 
> What exactly do you use such a scenario for?

IMQ because my shaping box counts as my 3rd PC and sometimes runs bt, 
mldonkey, wget.

After deNAT so I can do per user fairness.

Connbytes has dual use - I mark first 80KB of bulk tcp with it and send 
it to a shortish queue which I hacked to head drop and has half my 
512kbit bandwidth.

This either priorotises browsing in the presence of bulk or stops 
multiple connections in slowstart causing latency bumps if I am gaming 
and someone else is browsing big web pages.

Doesn't fix game + bulk + browsing - I think only a hack to htb/hfsc to 
have a class behave as full before it is would help this.

> 
> 
>>>If i was to prioritize my time for new actions - how important is this?
>>
>>Things are OK for me with IMQ - low bandwidth and not many filters seem 
>>fine. At high bandwidth/lots of filters it seems problematic - but then 
>>most people can use dummy now :-)
>>
>>I'll have to re-run a test I did recently which was lots of tc filter 
>>matches at 8000pps - on egress IMQ was almost as good as directly on 
>>eth0. On ingress it was more than 10X worse.
>>
> 
> 
> How many filters? I wont suspect any difference between ingress 
> and egress.

I'll have to run again to be sure but I saw a big difference - on egress 
I could generate 8000pps and have each packet tested by about 1500 filters.

On ingress I saw packet loss with only a couple of hundred or so - it 
was a tcp test though - so it backed off the loss was deduced by looking 
at netstat retrans on the sender I couldn't see it on any stats. This 
was with netperf. Maybe I should think of a better test - I tried udp 
and it whacked my PC so much I thought it had locked up.

> 
> Hey, you want to get started let me know ;-> Thomas and myself plan to
> do good documentation on the actions and ematch as they say Real Soon
> Now ;->

I look forward to reading them :-)

Andy.
