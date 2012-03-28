From: Davide Ciminaghi <ciminaghi@gnudd.com>
Subject: Re: [PATCH] net/ethernet: ks8851_mll fix rx frame buffer overflow
Date: Wed, 28 Mar 2012 12:51:20 +0200
Message-ID: <20120328105120.GE22721@mail.gnudd.com>
References: <20120327130144.GA555@recalcati> <1332859171.10620.0.camel@edumazet-laptop> <20120328070540.GA4892@recalcati> <1332920391.3547.46.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Raffaele Recalcati <raffaele.recalcati@bticino.it>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.gnudd.com ([213.203.150.91]:63812 "EHLO mail.gnudd.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753949Ab2C1Kvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 06:51:51 -0400
Content-Disposition: inline
In-Reply-To: <1332920391.3547.46.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 28, 2012 at 09:39:51AM +0200, Eric Dumazet wrote:
> On Wed, 2012-03-28 at 09:05 +0200, Raffaele Recalcati wrote:
> > Hi Eric,
> > 
> > On 07:39 Tue 27 Mar     , Eric Dumazet wrote:
> > > Le mardi 27 mars 2012 ?? 15:01 +0200, Davide Ciminaghi a ??crit :

...

> 
> So the limit should be 255, not 256.
> (0xFFFF >> 8 -> 0xFF)
> 
> ks->frame_cnt = ks_rdreg16(ks, KS_RXFCTR) >> 8;
> 
> I cant see how 256 can be stored in a 8bit field ?
>
you're right, we'll resend the patch with 255.
Well actually, since the chip appears to have 12K of internal rx buffers
and the shortest ethernet frame should be 64 bytes long, maybe the limit could
be set to 12*1024/64 = 192 frames, but I think 255 is safer.
 

Thanks and regards
Davide
