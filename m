From: CIT/FOONET Admin <xerox@foonet.net>
Subject: Serious weirdness w/ cbq and everything else
Date: Sat, 10 Aug 2002 03:40:00 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208100334110.10518-100000@foonix.foonet.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


I just can't get this to shape right.. I'm using 2.4.19-rc1 but I tried 
other versions..  what happens is it does not shape to the bandwidth I set 
it at.. sometimes no where even near it.. I just don't get it.. i even 
tried changing my HZ to 1000 and trying low latency patches, etc..  What's 
the deal?

My config is just something like this:

DEV=eth0

tc qdisc del dev $DEV root    2> /dev/null > /dev/null

tc qdisc add dev $DEV root handle 10:0 cbq bandwidth 100mbit avpkt 200 mpu 64

tc class add dev $DEV parent 10:0  classid 10:1 est 1sec 8sec  cbq bandwidth 250Kbit rate 250Kbit \
weight 25Kbit allot 1500 prio 3 minburst 64 maxburst 256 avpkt 128 cell 8 bounded

tc qdisc add dev $DEV parent 10:1 sfq quantum 1514b perturb 5

tc class add dev $DEV parent 10:0  classid 10:51 est 1sec 8sec  cbq 
bandwidth 100mbit rate \
   100Mbit allot 1514 prio 3 maxburst 10 cell 8 avpkt  500 bounded

tc qdisc add dev $DEV parent 10:51 tbf rate 1mbit buffer 2kb latency 100ms 
mtu 1514



then filters........ pointing to that.. i even added the rate estimator 
just recently and look what it shows:

class cbq 10:1 parent 10: leaf 800d: rate 250000bps cell 8b (bounded) prio 
3/3 weight 250bps allot 1514b
level 0 ewma 5 avpkt 200b
 Sent 6294040846 bytes 20138257 pkts (dropped 6644, overlimits 21092797)
 rate 241446bps 555pps
  borrowed 0 overactions 762540 avgidle 0 undertime -3


that class is actually doing about 2Mbps not .241Mbps like the estimator 
says.. i tried even setting the bandwidth to 2500000 bps as you see and it 
still lets it go over 5Mbps for i have no idea why except that the 
estimator shows 400000bps when it's doing 5Mbps for some odd reason.. that 
doesn't add up at all!!  Any ideas?

Paul
