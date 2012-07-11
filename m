From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 11:44:21 -0700
Message-ID: <4FFDC985.6050805@hp.com>
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
> Some bench results about the choice of 128KB being the default value:

What were the starting/baseline figures?

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
> Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 392360      392360      16384  20.00   1389.53    10^6bits/s  0.52  S      4.30   S      0.737   1.014   usec/KB

By the way, that double reporting of the local socket send size is fixed in:

------------------------------------------------------------------------
r516 | raj | 2012-01-05 15:48:52 -0800 (Thu, 05 Jan 2012) | 1 line

report the rsr_size_end in an omni stream test rather than a copy of the 
lss_size_end

of netperf and later.  Also, any idea why the local socket send size got 
so much larger with 1GbE than 10 GbE at that setting of 
tcp_limit_output_bytes?

> Tests on Gbit link :
>
>
> echo 16384 >/proc/sys/net/ipv4/tcp_limit_output_bytes
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.18 (172.30.42.18) port 0 AF_INET
> tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
> tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 30 tpci_snd_cwnd 274
> tcpi_reordering 3 tcpi_total_retrans 0
> Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 1264784     1264784     16384  20.01   689.70     10^6bits/s  0.22  S      15.05  S      0.634   7.149   usec/KB

rick jones
