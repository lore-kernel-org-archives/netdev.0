From: "CIT/Paul" <xerox@foonet.net>
Subject: RE: Route cache performance under stress
Date: Mon, 9 Jun 2003 18:56:18 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <008001c32eda$56760830$4a00000a@badass>
References: <20030609221911.GF11509@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>, <hadi@shell.cyberus.ca>,
	<fw@deneb.enyo.de>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "'Simon Kirby'" <sim@netnation.com>
In-Reply-To: <20030609221911.GF11509@netnation.com>
List-Id: netdev.vger.kernel.org

NAPI despises SMP.. Any SMP box we run NAPI on has major packet loss
under high load.. So I find that the e1000 ITR works just as well
And there is no reason for NAPI at this point. 

I will try your settings :)
net.ipv4.route.secret_interval = 600
net.ipv4.route.min_adv_mss = 256
net.ipv4.route.min_pmtu = 552
net.ipv4.route.mtu_expires = 600
net.ipv4.route.gc_elasticity = 4
net.ipv4.route.error_burst = 500
net.ipv4.route.error_cost = 100
net.ipv4.route.redirect_silence = 2048
net.ipv4.route.redirect_number = 9
net.ipv4.route.redirect_load = 2
net.ipv4.route.gc_interval = 600
net.ipv4.route.gc_timeout = 15
net.ipv4.route.gc_min_interval = 0
net.ipv4.route.max_size = 32768
net.ipv4.route.gc_thresh = 2000
net.ipv4.route.max_delay = 10
net.ipv4.route.min_delay = 5

Current settings....
Rtstat output:
size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
mc GC: tot ignored goal_miss ovrf
 2010      9014   14039     0     0     0     0     0         0       6
2   14038       0        49    0
 2008      8675   13999     0     0     0     1     0         1       5
2   13992       0        56    0
 2002      8529   16484     0     0     0     1     0         0       7
2   16483       0        43    0
 2009      8549   15304     0     0     0     0     0         1      10
2   15303       0        55    0
 2007      8491   16118     0     0     0     0     0         0      10
2   16117       0        50    0
 2024      8219   18306     0     0     0     1     0         0       7
2   18309       0        14    0
 2005      8586   15536     0     0     0     0     0         0       9
2   15536       0        42    0
 2007      8804   15797     0     0     0     0     0         0       7
2   15796       0        42    0
 2012      8535   16519     0     0     0     1     0         0       7
2   16518       0        28    0
 2004      8348   15709     0     0     0     0     1         0       8
2   15707       0        42    0
...
 2043      8600   18278     0     0     0     0     0         0      12
2   18285       0        15    0
 2030      8631   17731     0     0     0     1     0         0       9
2   17737       0         7    0
 2002      8489   14653     0     0     0     1     0         2       5
2   14650       0        35    0
 2015      8147   15004     0     0     0     0     0         0       9
2   15003       0        57    0
 2015      8352   17303     0     0     0     2     0         0       8
2   17308       0         7    0
 2025      8451   16768     0     0     0     0     0         0       6
2   16768       0        35    0
 2013      8531   16464     0     0     0     0     0         0      13
2   16476       0         7    0
 2013      8117   15202     0     0     0     1     1         0       7
2   15198       0        35    0
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
mc GC: tot ignored goal_miss ovrf
 2019      7913   15054     0     0     0     1     0         0       9
2   15057       0        42    0
 2008      8258   16019     0     0     0     0     0         1       9
2   16020       0        43    0
 2025      8211   17897     0     0     0     1     0         0       5
2   17902       0         0    0

CPU NORMAL:
CPU0 states: 36.0% user, 29.0% system,  0.0% nice, 33.0% idle
CPU1 states: 18.0% user, 61.0% system,  0.0% nice, 19.0% idle
CPU0 states: 21.0% user, 44.0% system,  0.0% nice, 35.0% idle
CPU1 states: 18.0% user, 47.0% system,  0.0% nice, 35.0% idle
    3 root      10  -1     0    0     0 SW<   0.0  0.0  35:29
ksoftirqd_CPU0
    4 root      10  -1     0    0     0 SW<   0.0  0.0  35:35
ksoftirqd_CPU1
 

Rtstat under light juno:

 2315      7955   51691     0     0     0     1     1         1       5
1   51695       0         0    0
 2336      6620   47387     0     0     0     1     0         1       5
1   47393       0         0    0
 2371      5630   49726     0     0     0     0     0         1      12
2   49737       0         0    0
 2372      5420   53458     0     0     0     1     0         0       2
1   53460       0         0    0
 2369      4891   48983     0     0     0     0     0         1       5
2   48988       0         0    0
 2389      4529   50525     0     0     0     0     1         1       8
1   50532       0         0    0
 2334      4645   49092     0     0     1     1     0         0       1
1   49093       0         0    0
 2358      5033   48971     0     0     0     1     0         1       6
2   48977       0         0    0
 2366      4864   51411     0     0     0     2     0         1       8
1   51419       0         0    0
 2370      5035   49444     0     0     0     0     0         0       4
2   49448       0         0    0
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
mc GC: tot ignored goal_miss ovrf
 2391      5328   49098     0     0     0     1     0         3      12
3   49110       0         0    0
 2363      5586   50687     0     0     0     2     0         0       7
1   50693       0         0    0
 2361      4571   49243     0     0     0     0     0         0       2
1   49243       0         0    0
 2356      5758   56664     0     0     1     1     0         1       5
1   56666       0         0    0
 2375      5581   62098     0     0     0     2     0         0       8
2   62103       0         0    0
 2393      3895   50762     0     0     0     1     0         0       5
0   50764       0         0    0
 2335      4066   56659     0     0     0     1     0         0      10
2   56667       0         0    0
 2315      3607   49990     0     0     0     1     0         0       4
1   49992       0         0    0
 2339      4369   54149     0     0     0     1     0         0       7
1   54153       0         0    0


CPU under JUNO:
CPU0 states:  0.0% user, 99.3% system,  0.2% nice,  0.0% idle
CPU1 states:  0.2% user, 99.3% system,  0.1% nice,  0.0% idle

    4 root      14  -1     0    0     0 SW<  21.0  0.0  35:33
ksoftirqd_CPU1
    3 root      15  -1     0    0     0 SW<  20.1  0.0  35:27
ksoftirqd_CPU0
  

This is 10mbit of juno....... Or around 9.6 or so...

RTS normal with 8000 thresh:
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
mc GC: tot ignored goal_miss ovrf
 8003     11474    9076     0     0     0     2     0         0       4
2    9071       0        10    0
 8010     11425    9205     0     0     0     0     0         0       7
2    9203       0        14    0
 8006     11393   12516     0     0     0     1     0         4       5
0   12509       0        20    0
 8005     12082    9188     0     0     0     2     0         0       5
2    9184       0        14    0
 8004     11447    8893     0     0     0     0     0         0       8
2    8890       0        12    0
 8004     12346    8898     0     0     0     1     0         2       5
2    8891       0        10    0
 8003     11557    8944     0     0     0     2     0         1       7
1    8942       0        14    0
 8004     12812    9890     0     0     0     0     0         1       5
1    9878       0        16    0
 8004     12166   11363     0     0     0     1     0         2       3
2   11349       0        23    0
 8012     11933    8881     0     0     0     2     0         0       6
2    8874       0        15    0
 8003     11938    9024     0     0     0     0     0         1       5
1    9017       0        12    0
 8003     12107    8682     0     0     0     1     0         2       3
2    8674       0        13    0
 8008     11328    8945     0     0     0     1     0         2       6
1    8942       0        10    0


CPU:
CPU0 states:  0.0% user, 50.0% system,  0.0% nice, 49.0% idle
CPU1 states:  1.0% user, 57.0% system,  0.0% nice, 40.0% idle

CPU0 states:  0.0% user, 27.0% system,  0.0% nice, 72.0% idle
CPU1 states:  0.0% user, 41.0% system,  0.0% nice, 58.0% idle

  3 root      12  -1     0    0     0 SW<   0.0  0.0  35:29
ksoftirqd_CPU0
    4 root       9  -1     0    0     0 SW<   0.0  0.0  35:35
ksoftirqd_CPU1
  


I've mucked with TONNnss of settings.. I've even had the route-cache up
to over 600,000 entries and the CPU still has room left for more..
It can't possibly be the size of the cache, it simply has to be the
constant creation and teardown of entries .. I can't hit anywhere NEAR
100kpps
On this router with the amount of load on it..

The routing table:

ip ro ls | wc
    516    2598   21032

Doesn't have too much in it.. It's running bgp but im not taking the
full routes right now.. We will later though.

There are some ip rules
Also some netfilters

 iptables-save | wc
   1154    7658   46126

Of course there isn't 1154 entries because some of that is the chains
and things but there are a lot of rules in netfilter also.. Everything
seems to slow it down :/ especially the mangle table.. If I add 1000
entries to the mangle table in netfilter it uses massive cpu ..
Netfilter seems to be a hog.


Like I said I've tested this with NO netfilter and nothing else on a
test box except for the kernel, e1000 , ITR set to ~4000 and all sorts
of changing the settings and I still can't hit 100kpps routing with
juno-z 


Paul xerox@foonet.net http://www.httpd.net


-----Original Message-----
From: Simon Kirby [mailto:sim@netnation.com] 
Sent: Monday, June 09, 2003 6:19 PM
To: CIT/Paul
Cc: 'David S. Miller'; hadi@shell.cyberus.ca; fw@deneb.enyo.de;
netdev@oss.sgi.com; linux-net@vger.kernel.org
Subject: Re: Route cache performance under stress


On Mon, Jun 09, 2003 at 03:38:30PM -0400, CIT/Paul wrote:

> gc_elasticity:1
> gc_interval:600
> gc_min_interval:1
> gc_thresh:60000
> gc_timeout:15
> max_delay:10
> max_size:512000

^^^ EEP, no!  Even the default of 65536 is too big.  No wonder you have
no CPU left.  This should never be bigger than 65536 (unless the hash is
increased), but even then it should be set smaller and the GC interval
should be fixed.  With a table that large, it's going to be walking the
buckets all of the time.

> I've tried other settings, secret-interval 1 which seems to 'flush' 
> the cache every second or 60 seconds as I have it here..

That's only for permutating the hash table to avoid remote hash
exploits. 
Ideally, you don't want anything clearing the route cache except for the
regular garbage collection (where the gc_elasticity controls how much of
it gets nuked).

> If I have secret interval set to 1 the GC never runs because the cache

> never gets > my gc thresh..  I've also tried this with Gc_thresh 2000 
> and more aggressive settings (timeout 5, interval 10).. Also tried 
> with max_size 16000 but juno pegs the route cache And I get massive 
> amounts of dst_cache_overflow messages ..

Try setting gc_min_interval to 0 and gc_elasticity to 4 (so that it
doesn't entirely nuke it all the time, but so that it runs fairly often
and prunes quite a bit).  gc_min_interval:0 will actually make it clear
as it allocates, if I remember correctly.

> This is 'normal' traffic on the router (using the rtstat program)

> 
> ./rts -i 1
>  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit
tot
> mc GC: tot ignored goal_miss ovrf
> 59272     26954    1826     0     0     0     0     0         6
0
> 0       0       0         0    0

Yes, your route cache is way too large for the hash.

Ours looks like this:

[sroot@r2:/root]# rtstat -i 1
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
mc
870721946     16394    1013     8     4     4     0     0        38
12      0
870722937     16278    1007     8     0    10     0     0        32
6      0
870723935     16362     999     5     0     6     0     0        34
8      0
870725083     16483    1158     1     0     0     0     2        26
6      0
870726047     16634     974     0     0     4     0     0        42
0      0
870726168     14315    2338    13    10     8     0     0        34
44      2
870726168     14683    1383     0     8     2     0     0        30
12      2
870726864     16172    1155     0     6     2     0     0        28
4      0
870728079     17842    1234     0     0     0     0     0        28
12      0
870729106     17545    1036     2     0     2     0     0        30
6      0

...Hmm, the size is a bit off there.  I'm not sure what that's all
about. 
Did you have to hack on rtstat.c at all?  Alternative:

[sroot@r2:/root]# while (1)
[sroot@r2:(while)]# sleep 1
[sroot@r2:(while)]# ip -o route show cache | wc -l [sroot@r2:(while)]#
end
   8064
   8706
   9299
   9939
  10277
  10857
  11426
  11731
  12328
  12796
  13096
  13623
   1139
   2712
   4233
    561
   2468
   3948
   5075
   5459
   6114
   6768
   7502
   7815
   8303
   8969
   9602
  10090
  10566
  11194
  11765
  11987
  12678
  12920
  13563
  14136
  14693
   2336
   3652
   4814
   5954
   6449
   6741
   7412
   8036

....Hmm, even that is growing a bit large.  Pfft.  I guess we were doing
less traffic last time I checked this. :)

Maybe you have a bit more traffic than us in normal operation and it's
growing faster because of that.  Still, with a gc_elasticity of 1 it
should be clearing it out very quickly.

...Though I just tried that, and it's not.  In fact, the gc_elasticity
doesn't seem to be making much of a difference at all.  The only thing
that seems to really change it is if I set gc_min_interval to 0:

[sroot@r2:/proc/sys/net/ipv4/route]# echo 0 > gc_min_interval
[sroot@r2:/proc/sys/net/ipv4/route]# while ( 1 ) [sroot@r2:(while)]#
sleep 1 [sroot@r2:(while)]# ip -o route show cache | wc -l
[sroot@r2:(while)]# end
   9674
   9547
   9678
   9525
   9625
   9544
   9385
    497
   2579
   3820
   4083
   4099
   4068
   4054
   4089
   4095
   4137
   4072
   4071
   4137
   2141
   3414
   4044
   2487
   3759
   4047
   4085
   4092
   4156
   4089
   4008
    475
   2497
   3729
   4146
   4085
   4116

It seems to regulate it after it gets cleared the first time.  If I set
gc_elasticity to 1 it seems to bounce around a lot more -- 4 is much
smoother.  It didn't seem to make a difference with gc_min_interval set
to 1, though... hmmm.  We've been running normally with gc_min_interval
set to 1, but it looks like the BGP table updates have kept the cache
from growing too large.

> Check what happens when I load up juno..

Yeah... Juno's just going to hit it harder and show the problems with it
having to walk through such large hash buckets.  How big is your routing
table on this box?  Is it running BGP?

> slammed at 100% by the ksoftirqds.  This is using e1000 with interrups

> limited to ~ 4000/second (ITR), no NAPI.. NAPI messes it up big time 
> and drops more packets than without :>

Hmm, that's weird.  It works quite well here on a single CPU box with
tg3 cards.

Simon-

