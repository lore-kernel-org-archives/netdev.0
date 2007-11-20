From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 17:03:12 +0300
Message-ID: <20071120140312.GA6695@2ka.mipt.ru>
References: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au> <20071119.222214.81458569.davem@davemloft.net> <4742C96D.3050203@myri.com> <20071120.035558.214794900.davem@davemloft.net> <4742E0A9.2070205@myri.com> <20071120133509.GA17377@2ka.mipt.ru> <20071120135056.GA18266@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Gallatin <gallatin@myri.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50744 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755673AbXKTODc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 09:03:32 -0500
Content-Disposition: inline
In-Reply-To: <20071120135056.GA18266@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 09:50:56PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Tue, Nov 20, 2007 at 04:35:09PM +0300, Evgeniy Polyakov wrote:
> > 
> > On Tue, Nov 20, 2007 at 08:27:05AM -0500, Andrew Gallatin (gallatin@myri.com) wrote:
> > > Hmm.. rather than a global tunable, what if it was a
> > > network driver managed tunable which toggled a flag in the
> > > lro_mgr features?  Would that be better?
> > 
> > What about ethtool control to set LRO_simple and LRO_ACK_aggregation?
> 
> I have two concerns about this:
> 
> 1) That same option can still be turned on by distros.

FC and Debian turn on hardware checksumm offloading in e1000 and I have
a card where this results in more than 10% performance _decrease_.
I do not know why, but Im able to run script which disables it via
ethtool.

> 2) This doesn't make sense because the code is actually in the
>    core networking stack.

It depends. Software lro can be controlled by simple procfs switch, but
hardware one? I recall it was number of times pointed that hardware LRO
is possible and likely being implemented in some asics.

> I'm particular unhappy about 2) because I don't want be in a
> situation down the track where every driver is going to add this
> option so that they're not left behind in the arms race.

For software lro I agree, but this looks exactly like gso/tso case and
additional tweak for software gso. Having it per-system is fine, and I
believe no one should ever care that some distro will do bad/good things
with it. Actually we do have so much tricky options in procfs already
which can kill performance...

-- 
	Evgeniy Polyakov
