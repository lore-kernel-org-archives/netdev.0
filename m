From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Thu, 8 May 2008 15:13:56 +0200
Message-ID: <200805081513.56521.mb@bu3sch.de>
References: <20080430124055.091382000@sipsolutions.net> <200805081500.00682.mb@bu3sch.de> <20080508130846.GA3769@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomasw@gmail.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:40011 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbYEHNOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 09:14:22 -0400
In-Reply-To: <20080508130846.GA3769@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 08 May 2008 15:08:46 Herbert Xu wrote:
> On Thu, May 08, 2008 at 03:00:00PM +0200, Michael Buesch wrote:
> >
> > Ok, what about DMA error. kmalloc error or something else?
> > ring overflow was a bad example, of course.
> 
> If your NIC gets DMA errors all the time then I suggest you
> invest in some new hardware.  Ditto if you fail to kmalloc all
> the time.
> 
> If they're rare as they should be then dropping the packet is
> perfectly reasonable.

Ok, why is nobody actually answering my _question_? :)
So I'll try to answer it by myself: the hard_start_xmit callback
is actually supposed to return "void", but it returns "int" just
for historical reasons. So there is no way to fail in a TX handler.
If a failure happens, the driver must free and drop the skb.
How likely errors are is a completely different story. One could argue
that errors are unlikely for any part of the kernel, except for very
sone special cases.

So does that also apply to the wireless stack? Should we change drivers
to always return 0. later we can change the function prototype to return void.

-- 
Greetings Michael.
