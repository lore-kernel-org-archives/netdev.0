From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 22:12:14 +0100
Message-ID: <16870.58414.767012.96364@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501121723.21969.jeremy.guthrie@berbee.com>
	<16870.14259.701771.389978@robur.slu.se>
	<200501131328.34449.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501131328.34449.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > I after a few revs I just bumped rhash_entries to 2.4mil in an attempt to get 
 > well above my actual usage. 

 A bit hefty size :-) But the stats are looking much better as we do much
 less linear search (in_search) in hash and less fib lookups (tot) 

 And you have now "dst cache overflows"?
 Is the e1000 patch I sent in use?

 > You can see below I am over 600K entries before it blows them away and 
 > restarts. 

 This is a part of GC process to reclaim memory and reclaim unused dst entries.
 This 

 >  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc 
 > GC: tot ignored goal_miss ovrf HASH: in_search out_search


 > 615852     86368     626     0     0     0     0     0         8       0      
 > 0     624     622         0    0           56504         10
 > 493558     47553    4603     0     0     0     0     0         2       0      
 > 0    4166    4164         0    0           28346          0
 > 10091     46526    7096     0     0     0     0     0         2       3      0       
 > 0       0         0    0             554          0
 > 16238     80565    6145     0     0     0     0     0         6       3      0       
 > 0       0         0    0            1334          0

 In short we reduce the hash size to remove unused flows and let it grow again. 
 You see from (tot) that we have recreate may of the flows at this point. Most 
 likely this is where we drop the packets. We have monitored small drops in our 
 system when GC happens. The GC can be smoothen out but we leave that for now.

 Is the e1000 patch I sent in use?

 > How do I bump up the time from 10 minutes to something longer?  

 Davem pointed out another periodic task thats flushes the cache totally it's

   /proc/sys/net/ipv4/route/secret_interval

 It flushes the cache totally we so all current flows has be recreated. You
 probably drop packets here in your setup. Yes it can be idea to increase it
 or run the flush manually. But most routers drop packets now and then.


						--ro
