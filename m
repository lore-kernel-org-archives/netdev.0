From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
 few uses of IRQF_SAMPLE_RANDOM
Date: Sun, 18 May 2008 12:13:35 +0200
Message-ID: <4830014F.9040800@firstfloor.org>
References: <20080515142154.0595e475@core>	<482C7DA3.1090809@garzik.org>	<482C953A.4080205@garzik.org>	<87abirytxj.fsf@basil.nowhere.org>	<20080516105635.6cb1f505@core>	<482D5FC5.2070103@firstfloor.org>	<20080516121239.GA9627@gondor.apana.org.au>	<482DB568.1040704@firstfloor.org>	<20080517010136.GA15102@gondor.apana.org.au>	<482EBAA8.3040506@firstfloor.org>	<a24804730805171254i2a37da61mb47280db7b330ed5@mail.gmail.com> <20080517130535.02d45372@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chris Peterson <cpeterso@cpeterso.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59700 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbYERKNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 06:13:37 -0400
In-Reply-To: <20080517130535.02d45372@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I think the big kicker is the difference between a session key (short
> lived) and a "real" key such as a gpg key that lives for a long time
> and is used for multile sessions and with different users (in crypto
> speak, Alice uses the same random key for Bob, Charlotte and David and
> potentially for a long time). For a session key, urandom is very likely
> an acceptable compromise; there's only so much data it's used for.
> For long term keys I can totally see why /dev/random is used instead.

We don't use it for most long term keys, e.g. ssh host keys. That is
because even on high entropy systems /dev/random usually doesn't work
during distribution installation because the system has not run long
enough to collect significant entropy yet.

See also the distinction between "user controlled visible cryptography"
and "background cryptography" I introduced in a earlier mail on that
topic. gpg can only get away with it because they rely on a high level
of user education (so requiring banging on keys is ok), but that's
not really an option for your normal "everyday background crypto",
including longer term keys.

So yes it's a nice theory, but without using the available randomness
sources always it doesn't work.

Instead I think just both urandom and random should try to rely
on TPMs and other hardware rngs and always get high quality bit noise.

-Andi


