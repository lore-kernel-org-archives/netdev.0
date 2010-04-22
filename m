From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 22:38:02 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
References: <1271941082.14501.189.camel@jdb-workstation>
 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
 <1271948029.7895.5707.camel@edumazet-laptop>  <20100422155123.GA2524@linux.vnet.ibm.com>
 <1271952128.7895.5851.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-324959784-1271968682=:10919"
Cc: paulmck@linux.vnet.ibm.com, Patrick McHardy <kaber@trash.net>,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1271952128.7895.5851.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-324959784-1271968682=:10919
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT


On Thu, 22 Apr 2010, Eric Dumazet wrote:

> Le jeudi 22 avril 2010 à 08:51 -0700, Paul E. McKenney a écrit :
>> On Thu, Apr 22, 2010 at 04:53:49PM +0200, Eric Dumazet wrote:
>>> Le jeudi 22 avril 2010 à 16:36 +0200, Eric Dumazet a écrit :
>>>
>>> If we can do the 'retry' a 10 times, it means the attacker was really
>>> clever enough to inject new packets (new conntracks) at the right
>>> moment, in the right hash chain, and this sounds so higly incredible
>>> that I cannot believe it at all :)
>>
>> Or maybe the DoS attack is injecting so many new conntracks that a large
>> fraction of the hash chains are being modified at any given time?
>>

I think its plausable, there is a lot of modification going on.
Approx 40.000 deletes/sec and 40.000 inserts/sec.
The hash bucket size is 300032, and with 80000 modifications/sec, we are 
(potentially) changing 26.6% of the hash chains each second.

As can be seen from the graphs:
  http://people.netfilter.org/hawk/DDoS/2010-04-12__001/list.html

Notice that primarily CPU2 is doing the 40k deletes/sec, while CPU1 is 
caught searching...


> maybe hash table has one slot :)

Guess I have to reproduce the DoS attack in a testlab (I will first have 
time Tuesday).  So we can determine if its bad hashing or restart of the 
search loop.


The traffic pattern was fairly simple:

200 bytes UDP packets, comming from approx 60 source IPs, going to one 
destination IP.  The UDP destination port number was varied in the range 
of 1 to 6000.   The source UDP port was varied a bit more, some ranging 
from 32768 to 61000, and some from 1028 to 5000.


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-324959784-1271968682=:10919--
