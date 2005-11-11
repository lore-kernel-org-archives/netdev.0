From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: RED qdisc not working...
Date: Fri, 11 Nov 2005 15:15:36 +0000
Message-ID: <4374B598.7000307@dsl.pipex.com>
References: <6278d2220511071626j3646afa7n5ac33228e8b3fc82@mail.gmail.com>
Reply-To: andy.furniss@dsl.pipex.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Daniel J Blueman <daniel.blueman@gmail.com>
In-Reply-To: <6278d2220511071626j3646afa7n5ac33228e8b3fc82@mail.gmail.com>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

Daniel J Blueman wrote:
> Has anyone been able to get the RED (random early detection) qdisc
> working lately?
> 
> I can't get anything going through it to be dropped or marked; the
> 'marked', 'early', 'pdrop' and 'other' fields remain at 0 [1]. In my
> example script [2], I get the 3072Kbits/s transfer into eth0, which
> you'd expect if the RED qdisc wasn't there.
> 
> I have tried with a recent 2.6.12 debian kernel and stock 2.6.14 on
> x86_64 debian. I built new iproute and iptables packages from latest
> clean upstream sources, but to no avail.
> 
> Any ideas? Please CC me on replies, as I am not subscribed.
> 
> Dan
> 
> --- [1]
> 
> # tc -s qdisc show dev eth0
> qdisc htb 1: r2q 10 default 10 direct_packets_stat 0
>  Sent 53985530 bytes 36757 pkts (dropped 0, overlimits 45125)
> qdisc red 10: parent 1:10 limit 512Kb min 64Kb max 128Kb
>  Sent 53985530 bytes 36757 pkts (dropped 0, overlimits 0)
>   marked 0 early 0 pdrop 0 other 0
> 
> --- [2]
> 
> tc qdisc del dev eth0 root
> 
> tc qdisc add dev eth0 root handle 1: htb default 10
> tc class add dev eth0 parent 1: classid 1:1 htb rate 4096kbit ceil 4096kbit
> tc class add dev eth0 parent 1:1 classid 1:10 htb rate 3072kbit ceil 3072kbit
> tc qdisc add dev eth0 parent 1:10 handle 10: red \
>   limit 4096kbit min 512kbit max 1024kbit avpkt 1000 \
>   burst 100 probability 0.02 bandwidth 1024kbit
> ___
> Daniel J Blueman

You need to test with several tcp connections, one will not have a big 
enough rwin to fill the queue enough to reach the buffer thresholds - 
which for clarity I would specify in kb not kbit.

Andy.


Andy.
