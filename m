From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: dummy as IMQ replacement
Date: Tue, 01 Feb 2005 01:02:12 +0000
Message-ID: <41FED514.7060702@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain> <20050131135810.GC31837@postel.suug.ch> <1107181169.7840.184.camel@jzny.localdomain> <20050131151532.GE31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050131151532.GE31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
>>Or dropping packets. TCP will adjust itself either way; at least
>>thats true according to this formula [rfc3448] (originally derived from
>>Reno, but people are finding it works fine with all other variants of
>>TCP CC):
>>
>>-----
>>The throughput equation is:
>>
>>                                   s
>>   X =  ----------------------------------------------------------
>>        R*sqrt(2*b*p/3) + (t_RTO * (3*sqrt(3*b*p/8) * p * (1+32*p^2)))
>>
>>
>>Where:
>>
>>      X is the transmit rate in bytes/second.
>>      s is the packet size in bytes.
>>      R is the round trip time in seconds.
>>      p is the loss event rate, between 0 and 1.0, of the number of loss
>>        events as a fraction of the number of packets transmitted.
>>      t_RTO is the TCP retransmission timeout value in seconds.
>>      b is the number of packets acknowledged by a single TCP
>>        acknowledgement.

WRT policers I never figured out where you would put the effects of 
playing with the burst size parameter and it's effects with few/many 
connections and any burstiness caused into an equasion like that.

>>----
> 
> 
> Agreed, this was my first attempt and my current code is still based on
> this. I'm trying to avoid a retransmit battle, therefore I try to
> delay packets if possible with the hope that it's either just a peak
> or the slow down is fast enough. I use a simplified RED and
> tcp_xmit_retransmit_queue() input to avoid flick flack effects which
> works pretty well for bulky streams. A burst buffer takes care
> of interactive traffic with peaks but this doesn't work perfectly fine
> yet. Overall, my attempt works pretty well if the other side uses
> reno/bic and quite well for westwood and vegas. The problem is not that
> it doesn't work at all but achieving a certain _stable_ rate is very
> difficult, the delta of the requested and real rate is up to 25% depending
> on the constancy of the rtt and wether they follow one of the proposed
> tcp cc algorithms. The cc guessing code helps a bit but isn't very
> accurate.
> 

This sounds cool. For me in someways I think it could be nicer (in the 
case of shaping from the wrong end of a slow link) to delay the real 
packets - that way the tcps of the clients get to see the smoothed 
version of the traffic and you can delay udp aswell.

How intelligent and how much, if any, per connection state do you/could 
you keep? I think being able to set a class that behaves as full before 
it is, removing the s from sfq, de piggybacking acks and singling out 
and handling slowstart connections specially could really help the world 
of shaping from the wrong end of slow links.

There's always playing with rwin, but maybe that's abit OTT :-)

Andy.
