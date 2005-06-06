From: "rahul hari" <rahulhsaxena@hotmail.com>
Subject: Re: [Linux Diffserv] GRED queueing discipline and the file sch_gred.c
Date: Tue, 07 Jun 2005 00:42:09 +0530
Message-ID: <BAY24-F180B77BFE5E7E1E24B7F31C5FB0@phx.gbl>
References: <20050606121527.GE15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: diffserv-general@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050606121527.GE15391@postel.suug.ch>
To: tgraf@suug.ch, hadi@cyberus.ca
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks for all the suggestions Jamal and Thomas.
>From what you people have been suggesting, i feel that i should be
giving a detailed explaination of the problem I am currently working on.

I have divided all the traffic on a network into 5 categories : Real
time video (UDP1),Real time audio (UDP2), TCP not requiring any QoS
(TCP1), TCP requiring QoS but with the size of the entire transaction
very low(TCP2), and TCP requiring QoS with the size of the transaction
in several MBs (TCP3).

Now I am putting UDP1 and TCP1 in one particular queue (say q1) and
giving priority to UDP1 (for dequeuing not caring if TCP1 is getting
starved). I am putting UDP2 ,TCP2 and TCP3 in a different queue (thus
keeping the average queue length almost constant) (say q2)and applying
RED on each of TCP2 and TCP3 (the application of the two REDs being
independent of each other). Here also I am providing priority to UDP2
(without caring if TCP2 or TCP3 is getting starved ).

To schedule between q1 and q2, I am using WRR and to schedule between
UDP1 and TCP1, I am using prio. For implementing q2, I am currently
putting UDP2,TCP2 and TCP3 in 3 different virtual queues and applying
GRED with grio. I am providing UDP2 the highest priority and providing
TCP2 and TCP3 equal priorities. To ensure that RED does not apply on
the UDP2, I have set Tmax=Tmin so that Pbmax=1. But the results I am
getting with this configuration do not match with the results that I
have got from the simulations.

So I want to implement this stuff such that the UDP2 gets highest
priority among the three, is not included while calculating the total
average queue length and the qave used for the application of REDs on
TCP2 and TCP3 should be equal to the qave of tcp2+ qave of tcp3.
To schedule between TCP2 and TCP3, I want to use WRR or something that
gives equal priority and prevents the starvation of any of these.

PS: please send any further replies to rahul.hari@cse06.itbhu.org instead of 
this account

Regards,
Rahul

-------
"The fear you let build up in your mind is worse than the situation that 
actually exists"
taken from "who moved my cheese"
-----------------------------------------------------------------------------
Rahul Hari
Senior Undergraduate Student,
Department of CSE,
ITBHU,
Varanasi.
Ph: +91-9845347020
-----------------------------------------------------------------------------


>
>* jamal <1118058859.6266.126.camel@localhost.localdomain> 2005-06-06 07:54
> > On Mon, 2005-06-06 at 13:39 +0200, Thomas Graf wrote:
> >
> > > Use a prio qdisc with RED leaf qdiscs. RED and GREDs purpose is to
> > > calculate a marking probability and not to provide any prioritizing
> > > schemes.
> >
> > Prioritization is still implicitly provided if you vary the queue
> > lengths or the drop probabilities.
> > For example, if you set everything to be exactly the same, and varied
> > only the drop probability - the VQ with the highest drop probability
> > will be less important (i.e relatively more of its packets will be
> > dropped; recall: the drop decision is made before the packet is queued).
>
>Absolutely, what I meant is that GRED does not take influence on the
>actual ordering of packets not dropped. The priority together with
>the qavg parameters and the thresholds only have influence on the
>probability a packet gets marked/dropped, sure this is prioritization
>as well but Rahul wanted to have one VQ strave out another VQ
>completely. My point is that this is not possible with GRED.

_________________________________________________________________
Think Rani is the best? http://server1.msn.co.in/sp05/iifa/ Make sure she 
wins the award.
