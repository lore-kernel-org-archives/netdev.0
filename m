From: "CIT/Paul" <xerox@foonet.net>
Subject: RE: Route cache performance under stress
Date: Mon, 9 Jun 2003 15:38:30 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <004f01c32ebe$b4bd88d0$4a00000a@badass>
References: <20030609082718.GG20613@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>, <hadi@shell.cyberus.ca>,
	<fw@deneb.enyo.de>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "'Simon Kirby'" <sim@netnation.com>
In-Reply-To: <20030609082718.GG20613@netnation.com>
List-Id: netdev.vger.kernel.org

gc_elasticity:1
gc_interval:600
gc_min_interval:1
gc_thresh:60000
gc_timeout:15
max_delay:10
max_size:512000
min_adv_mss:256
min_delay:5
min_pmtu:552
mtu_expires:600
redirect_load:2
redirect_number:9
redirect_silence:2048
secret_interval:60


I've tried other settings, secret-interval 1 which seems to 'flush' the
cache every second or 60 seconds as I have it here..
If I have secret interval set to 1 the GC never runs because the cache
never gets > my gc thresh..  I've also tried this with
Gc_thresh 2000 and more aggressive settings (timeout 5, interval 10)..
Also tried with max_size 16000 but juno pegs the route cache
And I get massive amounts of dst_cache_overflow messages .. 
This is 'normal' traffic on the router (using the rtstat program)

./rts -i 1
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
mc GC: tot ignored goal_miss ovrf
59272     26954    1826     0     0     0     0     0         6       0
0       0       0         0    0
35188     24721    4901     0     0     0     1     0         7       4
0       1       0         0    0
40170     23820    4978     0     0     0     1     0         6       5
0       0       0         0    0
43674     24630    3503     0     0     0     0     0         6       2
0       0       0         0    0
46857     24889    3184     0     0     0     1     0         5       0
0       0       0         0    0
  809     26110    3394     0     0     0     1     2         8       6
0       0       0         0    0
13898     14370   13322     0     0     0     0     1         2       6
2       0       0         0    0
22309     19823    8408     0     0     0     1     0         3       3
0       0       0         0    0
27857     21905    5543     0     0     0     1     0         3       5
0       0       0         0    0
32572     23521    4712     0     0     0     0     0         3       3
0       0       0         0    0
35863     25057    3287     0     0     0     1     0         5       4
0       0       0         0    0
39431     25769    3567     0     0     0     1     0         5       4
0       0       0         0    0
43114     25681    3686     0     0     0     0     0         3       1
0       0       0         0    0
46143     26140    3031     0     0     0     1     0         5       1
0       0       0         0    0
49158     28385    3015     0     0     0     1     0         8       4
0       0       0         0    0
52053     29708    2896     0     0     0     0     0         3       1
0       0       0         0    0

You can see where the secret interval hits and the size goes back down
to nothing.  Also you can see the garbage collection
Kicking in at high pace in the first 2 lines when it hits the thresh it
knocks it down hard and doesn't even show in the gc stats on the right.
This seems to be a good compromise for now.. 

Check what happens when I load up juno..
52253     26156    2933     0     0     0     1     0         5       3
0       0       0         0    0
54313     25429    2061     0     0     0     0     0         4       0
0       0       0         0    0
56467     25754    2153     0     0     0     0     0         9       1
0       0       0         0    0
39980     28341   12497     0     0     0     3     0         8       2
0       1       0         0    0
62200     21112   63032     0     0     0     0     0         0       5
2   15124   15123         0    0
41754     12345   52282     0     0     0     2     0         2       7
1   18776   18774         0    0
49139      8263   42314     0     0     0     0     0         0       1
1   12191   12190         0    0
55385      8256   42518     0     0     0     0     0         2       4
0   14904   14903         0    0
57413      7308   38594     0     0     0     3     0         1       3
1   15545   15544         0    0
59604      7254   38850     0     0     0     0     0         0       1
1   15703   15702         0    0
66136      7835   43335     0     0     0     0     0         0       7
1   22191   22190         0    0
66570      7095   37265     0     0     0     2     0         0       1
1   16560   16559         0    0
69269      6786   39392     0     0     0     0     0         0       1
1   18516   18515         0    0
72988      7749   40492     0     0     0     0     0         0       7
1   19735   19734         0    0
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
mc GC: tot ignored goal_miss ovrf
46461      8398   47142     0     0     0     1     0         0       1
1   19312   19310         0    0
58837      8325   49347     0     0     0     1     0         1       4
0   16369   16368         0    0
59948      6691   38094     0     0     0     1     0         1       5
2   16392   16391         0    0
63364      7442   40269     0     0     0     0     0         0       1
0   19528   19527         0    0
64597      7110   38179     0     0     0     0     0         1       5
1   17534   17533         0    0
68520      7306   40842     0     0     0     0     0         0       5
2   20153   20152         0    0
70807      6840   39230     0     0     0     1     0         0       1
0   18631   18630         0    0
73130      6534   39318     0     0     0     1     0         2       3
0   18805   18804         0    0
75149      7038   39141     0     0     0     0     0         0       4
1   18719   18718         0    0
75775      6486   37682     0     0     0     1     0         0       1
1   17183   17182         0    0
53219      8605   51413     0     0     0     2     0         0       9
1   17099   17097         0    0
57124      6977   40914     0     0     0     0     0         1       1
1   16465   16464         0    0
62052      7460   41935     0     0     0     2     0         1       1
1   18499   18498         0    0

Ok you see this happening but during this the router is almost
unusable..   
PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME COMMAND
    3 root      20  -1     0    0     0 RW<  48.5  0.0  34:04
ksoftirqd_CPU0
    4 root      20  -1     0    0     0 RW<  46.7  0.0  34:14
ksoftirqd_CPU1

And this is only about 15mbps of juno-z, of course this is a production
router so I don't want to do any more than that so we don't drop any
'real' packets also but it gives a good real world test.. Both cpus are
slammed at 100% by the ksoftirqds.  This is using e1000 with interrups
limited to ~ 4000/second (ITR), no NAPI.. NAPI messes it up big time and
drops more packets than without :>

I'll load this all up on the test router and do the profiling and test
dave's patches later when I get a chance 


Paul xerox@foonet.net http://www.httpd.net


-----Original Message-----
From: Simon Kirby [mailto:sim@netnation.com] 
Sent: Monday, June 09, 2003 4:27 AM
To: CIT/Paul
Cc: 'David S. Miller'; hadi@shell.cyberus.ca; fw@deneb.enyo.de;
netdev@oss.sgi.com; linux-net@vger.kernel.org
Subject: Re: Route cache performance under stress


On Mon, Jun 09, 2003 at 04:10:55AM -0400, CIT/Paul wrote:

> I've got juno-z.101f.c to send 500,000 pps at 300+mbit on our dual p3 
> 1.26 ghz routers.. I can't even send 50mbit of this though one of my 
> routers Without it using 100% of both cpus because of the route 
> cache.. It goes up to 500,000 entries if I let it and it adds 80,000 
> new entries per second and they are all cache misses.. I'd be glad to 
> show you the setup sometime :) I showed it to jamal and we tested some

> stuff.

Hmm.. We're running on single 1800MP Athlons here.  Have you had a
chance to profile it? 

- add "profile=1" to the kernel command line
- reboot
- run juno-z.101f.c from remote box
- run "readprofile -r" on the router
- twiddle fingers for a while
- run "readprofile -n -m your_System.map > foo"
- stop juno :)
- run "sort -n +2 < foo > readprofile.time_sorted"

I'm interested to see if your profile results line up to what I'm seeing
here on UP (though I have the kernel compiled SMP...Oops).

Wait a second... 500,000 entries in the route cache?  WTF?  What is your
max_size set to?  That will massively overfill the hash bucket and
definitely take up way too much CPU.  It shouldn't be able to get there
at all unless you have raised max_size.  Here I have:

echo 4 > gc_elasticity          # Higher is weaker, 0 will nuke all
[dfl: 8]
echo 1 > gc_interval            # Garbage collection interval (seconds)
[dfl: 60]
echo 1 > gc_min_interval        # Garbage collection min interval
(seconds) [dfl: 5]
echo 90 > gc_timeout            # Entry lifetime (seconds) [dfl: 300]

[sroot@r1:/proc/sys/net/ipv4/route]# grep . *
...
gc_elasticity:4
gc_interval:1
gc_min_interval:1
gc_thresh:4096
gc_timeout:90
max_delay:10
max_size:65536

Simon-

