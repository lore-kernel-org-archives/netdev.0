From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 29 Sep 2004 09:55:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096466106.1024.29.camel@jzny.localdomain>
References: <20040928032321.GB10116@gondor.apana.org.au>
	 <1096343125.8661.96.camel@jzny.localdomain>
	 <20040928035921.GA10675@gondor.apana.org.au>
	 <1096367787.8662.146.camel@jzny.localdomain>
	 <20040928111159.GA18421@gondor.apana.org.au>
	 <1096374736.8663.217.camel@jzny.localdomain>
	 <20040929001327.GB25293@gondor.apana.org.au>
	 <1096426324.1044.129.camel@jzny.localdomain>
	 <20040929032724.GA26959@gondor.apana.org.au>
	 <1096455046.1044.189.camel@jzny.localdomain>
	 <20040929114234.GD29516@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040929114234.GD29516@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-29 at 07:42, Herbert Xu wrote:

> I presume that the ifdown script you posted fits this description?

Probably not a good fit. A good fit (not sure how to create the race)
is to have (handwave to illustrate) 1000 netdevices getting downed. You
get notified of first 50, overrun happens, then you get last 30 of last
50 and then another overrun. And somewhere in the second overrun you
lost notification that the netdevices 5-8 infact came up.
A scheme which polls every X seconds from user space will catch this
of course but depending on how you do it the latency will vary.

> I agree this is suboptimal.  However, I don't see how the intermediate
> queue can help here.
> 

The intermidiate queue was just brainstorming. It is based on something
that i tried with taps - may not be the best approach and at the end we
may just say we are better off leaving things as they are. The
intermidiate queue is a classical approach to manage disparity between
speed and buffer mismatching in a case when you either have multiple
senders or receivers (in our case).
The idea behind it being that if i am going to overflow it with
1000 events then i am pretty sure that none of the user space apps
cannot handle that load.

> Hmm, I suspect that there is something broken here that's causing the
> overruns.  Let me have a play with your script/ip monitor and get back
> to you.
> 
> > I dont think 10 are a big deal but multiply by some factor and the cost
> > is clear to quantify.
> 
> Agreed.  Perhaps what we need is a way to identify these messages as
> related.  If you can do that then the kernel can forget about them
> when an overrun occurs.

Theres a lot of things that netlink needs to improve on, this being one.
I dont wanna go over the laundry list but it will need major surgery
and will break backward compatibility. I know you are a fireman and will
go fixing things - so i aint telling you yet ;-> (more worried we'll put
solutions that may get us going as bandaids and postpone the surgery).
In all fairness you could use the sequenece number as a transaction
identifier will require more management.
 
> I still don't see this as a big deal though since the application can
> always weather the storm by closing the socket after an overrun,
> sleeping for a while and then reopen it to listen again.
> 
> > If you insist however, heres one i can visualize thats a legit get from
> > a semantic view:
> > A get of a table entry which itself happens to be a table (and if you
> > want to be funnier maybe three level deep table). You do a get on a
> > table entry, you get a _whole table_ back. 
> 
> That's easy :) Anything that's a table should use dump.  

Thats why i emphasized "legit get from a semantic view" ;->
Assuming you know the item you are getting is a table, yes indeed;
however, it does get tiring and abuse of human intelligence to say "dump
table X which is found in entry a of table B which is found in entry c
of table D which is found in entry e of table F which itself is found it
table G entry h .." 
instead of just saying "get entry a of table X"

> Remember that
> dump can take parameters just like get.  So there's nothing wrong with
> using dump to get an entry which happens to be a table.

> PS We've managed to cut down the size of our emails by half.  Shows that
> congestion control is certainly working on this mailing list :)

Shall we include brazillian coffee as a parameter in congestion
control?;-> 

cheers,
jamal
