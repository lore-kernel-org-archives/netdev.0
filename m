From: jamal <hadi@cyberus.ca>
Subject: RE: TxDescriptors -> 1024 default. Please not for every NIC!
Date: 05 Jun 2004 10:37:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086446277.1592.205.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0406021235200.17290-100000@fast2.cs.caltech.edu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marc Herbert <marc.herbert@free.fr>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.44.0406021235200.17290-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-06-02 at 15:49, Cheng Jin wrote:
> Marc,
> 
> In general, I very much agree with what you have stated about not having
> a large txqueuelen.  Txqueuelen should be something that alleviates
> the mismatch between CPU speed and NIC transmission speed,

Thats the theory. More interesting of course are bus speeds, arbitration
schemes,  RAM latencies and throughput and other dynamic bottlenecks
like system loads. 

>  temporarily.
> As long as the txqueuelne is greater than zero, say 10 just to be safe, 
> NIC will be running at full speed (unless there were inefficiencies in 
> scheduling) so there is no incentive in setting it to be an excessively 
> large value like 1000.

In theory as well, the only time you even need to queue is when theres
congestion..
In reality, totaly different ballgame. In other words its not a simple
system that you can throw Littles theorems at.

Marc, good email, at least you didnt hand wave and declare the wind was
blowing towards the south today.

My opinion:
I agree that the 1000 qlen is excessive for 10/100 - infact i think the
value should dynamically adjust itself even for gige capable NICs
(example if a gige NIC negotiates a 10Mbps speed with link partner, then
you should adjust the qlen)[1]. That wont be trivial to do - but more
importantly motivation lacks because i dont think the situation we have
right now is devastating. To clarify:
A single TCP flow will fill in any pipe you give it under proper
conditions (proper congestion control algorithms, buffer etc)[2]. 
Most apps using TCP dont care very much about latency; the only
exception would be some scientific clustering technologies using TCP for
control messaging. And for those type of apps, you should be able to 
tune the qlen to your liking using tc or ip utilities (I claim they
shouldnt be using tcp to begin with, but thats another discussion). If
you dont want to take that extra step to tune then you dont care, and
IMO you shouldnt complain.

Having said all that: i still think theres value in maybe issuing a
warning or making the default qlen selection a compile time config.


cheers,
jamal

[1] I think it would make a nice project for someone with time. I can
consult for anyone interested.
[2] Looking at the recent patches on BIC, it does seem pretty agressive
and should have no problem filling a 10Gige pipe with proper processing
power.
