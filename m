From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 01:46:38 +0400
Message-ID: <20041031014638.596da2a5@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<1099053738.1024.104.camel@jzny.localdomain>
	<20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	<41824D9A.3070407@logix.cz>
	<20041029183606.0b1a0538@zanzibar.2ka.mipt.ru>
	<Pine.LNX.4.61.0410291636020.25667@maxipes.logix.cz>
	<20041029192741.5344ad0f@zanzibar.2ka.mipt.ru>
	<20041030203906.GC6256@gate.ebshome.net>
	<20041031011719.07858890@zanzibar.2ka.mipt.ru>
	<20041030210915.GE6256@gate.ebshome.net>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michal Ludvig <michal@logix.cz>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Eugene Surovegin <ebs@ebshome.net>
In-Reply-To: <20041030210915.GE6256@gate.ebshome.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004 14:09:15 -0700
Eugene Surovegin <ebs@ebshome.net> wrote:

> On Sun, Oct 31, 2004 at 01:17:19AM +0400, Evgeniy Polyakov wrote:
> > On Sat, 30 Oct 2004 13:39:06 -0700
> > Eugene Surovegin <ebs@ebshome.net> wrote:
> > 
> > > On Fri, Oct 29, 2004 at 07:27:41PM +0400, Evgeniy Polyakov wrote:
> > > > but it was designed to be usefull only in custom MX box, 
> > > 
> > > This is not true. I coded it using Hifn PCI card plugged in 440GP eval 
> > > board as well in P4 2.6 GHz box.
> > > 
> > > Driver isn't perfect, it's quite simple, I suspended all work on it 
> > > because without async crypto it doesn't make a lot of sense.
> > > 
> > > > so it has some design notes that I do not agree with.
> > > 
> > > And they are (I know there are problems, just curious which ones you 
> > > "don't agree with") ? 
> > 
> > It supports only one card, 
> 
> Yes, and comment says it trivially fixed  :)
> 
> > it has very nontrivial locking, 
> 
> locking is really simple, it was obviously done for current sync 
> crypto layer.

Current locking just can not be used tu support several sessions to be 
processed in a parallel, although hardware support it, not?
Probably it is not driver problem, but what do we try to figure out?
With current crypto it can work - good, with acrypto it must be completely 
rewritten.

> > which may(I'm not sure after just finished diagonal review) lead to 
> > too big latencies,
> 
> Huh?

neither will hifn_cipher() busy-wait until request processing will be finished
if it happens in interrupt context? 

> > hifn_cipher() can not work with any other crypto design, 
> 
> Well, this funny one :). Of course it cannot, because none existed 
> when I wrote it. 

It was written _only_ for syncronous events.
I think only HW initialization bits can be copied into future version, 
but again, what do we discuss and/or accuse? :)
 
> If your async stuff will be accepted into the official kernel tree 
> I'll re-write it ASAP.
> 
> > I doubt it can  work with other card capabilities other then you 
> > have implemented without major rewrite.
> 
> Hmm, what do you mean "other" card? It's written for particular 
> Hifn chip. I wrote it for IPSec acceleration in mind. Some algorithms 
> aren't supported (compression for example), because we don't use 
> them.

I mean other capabilities not card.

> > I'm quite sure it is good driver for current crypto schema, but if
> > acrypto will be committed it could not work without complete rewrite.
> 
> Yes, that's true :). That's the reason I never officially announced it, 
> because current one is quite trivial, and there are a lot of things 
> which can be improved upon, after async crypto is in, and IPSec uses 
> it.
> 
> --
> Eugene


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
