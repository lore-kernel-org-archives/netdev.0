From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 19:37:20 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029193720.53235ec3@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<1099053738.1024.104.camel@jzny.localdomain>
	<20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	<1099062483.1023.21.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099062483.1023.21.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Oct 2004 11:08:03 -0400
jamal <hadi@cyberus.ca> wrote:

> On Fri, 2004-10-29 at 10:06, Evgeniy Polyakov wrote:
> 
> 
> > If we have a hardware accelerator chip, than we _already_ have improvements 
> > with even the worst async crypto layer, since software and hardware 
> > will work in parrallel.
> 
> Thats what i am hoping - and theory points to it. Numbers, numbers
> please ;->

Michal already have numbers with his patches, that(I studied crypto-dev patch) 
implements acrypto not from the scratch but as a addendum for syncronous crypto
layer, so this approach already has nitpicks.

> > I agree that multigigahertz box will beat my HIFN card, 
> > but I doubt it can beat 1gghz VIA.
> 
> The VIA is an interesting one; but it would still be interesting to see 
> comparisons.
> Actually I should say a good comparison will be with a dual opteron
> >= 2Ghz which i have no doubt will smoke a xeon - all in s/ware.

He-he, dual Opteron? It costs as 5 Via boards :)

ok, I will follow this plan:
I will create simple block device like cryptoloop, it will be _really_ simple
without any kind of portability and/or stability (I hope it will be
one day, at least it took so for 2.4) and I will measure async vs sync.
Then Michal can measure it's fcrypt driver also.

> > And what about random numbers, async crypto, TPM?
> > They all requires some kind of generalization.
> > 
> 
> Similar deferal approach should do it.
> If you are brave, you should probably experiment as well with
> non-crypto stuff to defer things like gettimeofday computes.
> (i.e ask the hardware for time, defer response and then call netif_rx
> with a tag saying time has been computed).

gettimeofday is to fast to use in async schema - in such times
context switching already plays big role.

> cheers,
> jamal
> 
> 


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
