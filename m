From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 11:23:09 -0700
Message-ID: <4FFDC48D.2030606@hp.com>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
	<1341933215.3265.5476.camel@edumazet-glaptop>
	<1342019518.3265.8116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, mattmathis@google.com,
	codel@lists.bufferbloat.net, ncardwell@google.com,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1342019518.3265.8116.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On 07/11/2012 08:11 AM, Eric Dumazet wrote:
>
>
> Tests using a single TCP flow.
>
> Tests on 10Gbit links :
>
>
> echo 16384 >/proc/sys/net/ipv4/tcp_limit_output_bytes
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.99.2 (192.168.99.2) port 0 AF_INET
> tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
> tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 16 tpci_snd_cwnd 79
> tcpi_reordering 53 tcpi_total_retrans 0

I take it you hacked your local copy of netperf to emit those?  Or did I 
leave some cruft behind in something I committed to the repository?

What was the ultimate limiter on throughput?  I notice it didn't achieve 
link-rate on either 10 GbE nor 1 GbE.

 > Thats the plan : limiting numer of bytes in Qdisc, not number of bytes
 > in socket write queue.

So the SO_SNDBUF can still grow rather larger than necessary?  It is 
just that TCP will be nice to the other flows by not dumping all of it 
into the qdisc at once.  Latency seen by the application itself is then 
unchanged since there will still be (potentially) as much stuff queued 
in the SO_SNDBUF as before right?

rick
