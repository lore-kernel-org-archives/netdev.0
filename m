From: bert hubert <ahu@ds9a.nl>
Subject: Re: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 15:49:08 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020730134908.GA26100@outpost.ds9a.nl>
References: <20020730131424.GA25238@outpost.ds9a.nl> <200207301331.RAA03211@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@zip.com.au, jgarzik@mandrakesoft.com,
   becker@scyld.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200207301331.RAA03211@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, Jul 30, 2002 at 05:31:44PM +0400, kuznet@ms2.inr.ac.ru wrote:

> Well, try to prove that corrupted packet is really received by application.
> This is not useless work, in any case, you have to cure this place,
> it should not abort because of invalid data. :-)

We fixed the bug already :-) Signed/unsigned arithmetic problems.

I have six examples in my log of PowerDNS exiting just after receiving a
packet with a broken checksum. Now, I know that this is particle physics
kind of statistical evidence :-) but I think it is pretty solid.

Furthermore, I see answers being sent out to questions with broken
checksums. Even more enticing is that all bad checksums come from a small
number of hosts, 61.222.31.205, 64.58.142.2 and 202.106.0.21. So this would
be pretty unlikely for a tcpdump bug.

Here are some answers to questions with a bad udp checksum. Note that the
DNS question id (8, 9 and 8 in this case) matches over question and answer,
which is pretty conclusive evidence that userspace saw the packet.

08:06:53.097420 61.222.31.205.63240 > 213.244.168.217.53:  [bad udp cksum
4c83!] 8 op5 [2a][|domain] (ttl 112, id 444, len 109)

08:06:53.097693 213.244.168.217.53 > 61.222.31.205.63240:  [udp sum ok] 8
op5 NotImp*- q:[|domain] (DF) (ttl 64, id 0, len 52)

==

02:48:03.404865 61.222.31.205.62869 > 213.244.168.217.53:  [bad udp cksum
7a20!] 9 op5 [2a][|domain] (ttl 112, id 1277, len 109)   

02:48:03.405045 213.244.168.217.53 > 61.222.31.205.62869:  [udp sum ok] 9
op5 NotImp*- q:[|domain] (DF) (ttl 64, id 0, len 52)

==

03:20:36.514897 61.222.31.205.63268 > 213.244.168.217.53:  [bad udp cksum
b94d!] 8 op5 [2a][|domain] (ttl 112, id 2317, len 109)   

03:20:36.515094 213.244.168.217.53 > 61.222.31.205.63268:  [udp sum ok] 8
op5 NotImp*- q:[|domain] (DF) (ttl 64, id 0, len 80)

> As a faster hint try to disable rx checksumming in the driver
> and look at the effect. I do not see module option to do this,
> so probably you have just to comment out the place where
> skb->ip_summed is set to CHECKSUM_UNNECESSARY.

Ok, will do when we are near to the machine again. 

Regards,

bert hubert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
