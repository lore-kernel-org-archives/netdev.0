From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 18:36:06 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029183606.0b1a0538@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<1099053738.1024.104.camel@jzny.localdomain>
	<20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	<41824D9A.3070407@logix.cz>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <michal@logix.cz>
In-Reply-To: <41824D9A.3070407@logix.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 16:03:06 +0200
Michal Ludvig <michal@logix.cz> wrote:

> Evgeniy Polyakov told me that:
> > On 29 Oct 2004 08:42:18 -0400
> > jamal <hadi@cyberus.ca> wrote:
> > 
> >>>I am very curious if you see perfomance improvements over old scheme
> >>in the case of a single crypto chip in a fast CPU.
> >>It has been shown in the past that with a xeon in the range of 2Ghz the
> >>context setup and the big lock (and lack of async) implied that
> >>performance enhancement using a crypto chip was negligible.
> >>IIRC, the only time it started showing anything useful was when a
> >>compute intensive alg like 3DES was chewing packets >= 1000 bytes.
> >>
> >>My suspicion is you will show it is better to use a crypto chip with
> >>async;-> In the minimal you should show some improvement.
> > 
> > 
> > If we have a hardware accelerator chip, than we _already_ have improvements 
> > with even the worst async crypto layer, since software and hardware 
> > will work in parrallel.
> > I agree that multigigahertz box will beat my HIFN card, 
> > but I doubt it can beat 1gghz VIA.
> 
> I have a very preliminary driver for FastCrypt PCI board for 3DES at
> http://www.logix.cz/michal/devel/fcrypt/
> For now it works with some very ugly hacks in the current cryptoapi, but
> I can give it a try with your acrypto and report the results.

It would be very appreciated>
 
> I admit I haven't read your sources too deeply yet so excuse me a dumb
> question - does acrypto replace or extend cryptoapi? Once I get it
> running will it take over e.g. encryption for IPsec?

They are both an addendum to each other, 
any crypto layer can be "tunrned into compatibility mode" - 
i.e. anyone can write bridges like attached sha1_provider.c (it is bridge
from async into sync mode). So I can not answer - but in _current_ 
implementation without any kind of bridges it is an extension.

If you compile this sources then you will still have old sync behaviour, 
IPsec and any other old-style application should be rewritten(like 
attached consumer.c) to use new asynchronous crypto layer features.
 
> Michal Ludvig
> -- 
> * A mouse is a device used to point at the xterm you want to type in.
> * Personal homepage - http://www.logix.cz/michal
> _______________________________________________
> 
> Subscription: http://lists.logix.cz/mailman/listinfo/cryptoapi
> List archive: http://lists.logix.cz/pipermail/cryptoapi


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
