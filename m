From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 27 Sep 2004 23:06:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096340772.8659.51.camel@jzny.localdomain>
References: <20040922000503.GA13218@gondor.apana.org.au>
	 <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au>
	 <1095854920.1047.64.camel@jzny.localdomain>
	 <20040923120707.GB32624@gondor.apana.org.au>
	 <1095995042.1044.34.camel@jzny.localdomain>
	 <20040924032440.GB6384@gondor.apana.org.au>
	 <1096289189.1075.37.camel@jzny.localdomain>
	 <20040927213607.GD7243@gondor.apana.org.au>
	 <1096339407.8660.33.camel@jzny.localdomain>
	 <20040928024614.GA9911@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040928024614.GA9911@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-27 at 22:46, Herbert Xu wrote:
> On Mon, Sep 27, 2004 at 10:43:27PM -0400, jamal wrote:
> > On Mon, 2004-09-27 at 17:36, Herbert Xu wrote:
> > 
> > > You still haven't told me what you're going to use 3) for yet...
> > 
> > Sorry, keep forgetting to retrieve it from other remote non-networked
> > test machine. The idea is:
> > Create something that generates lots of messages. Make socket buffer
> > small (4096 is good nuf)
> 
> No that's not what I meant.  What I mean is what is the real-world
> scenario where you're going to be doing 3).

The real world scenario is just that: Massive events generated from the
kernel for example

> Only when we know where the messages are coming from and what they
> are can we decide on a meaningful method of limiting their rate.

Ok, heres a sample testcase i created just now following those same
instructions i gave you ;->

---
#!/bin/sh

ifconfig dummy0 1.2.1.1 netmask 255.255.255.0 broadcast 1.2.1.255 up
ifconfig dummy0:0 1.2.1.1
for ((i = 1 ; i <= $1 ; i++))
do
        ifconfig dummy0:$i 1.2.1.$i
done
---

pass 100 to it to create 100 aliases; you may not need to setsock to
4096, but thats what i did. 

down dummy0:0 and see the overrun.

cheers,
jamal
