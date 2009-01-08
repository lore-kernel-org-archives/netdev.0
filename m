From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Thu, 08 Jan 2009 19:25:01 +0000
Message-ID: <1231442701.3893.4.camel@achroite>
References: <200901080203.SAA19103@tardy.cup.hp.com>
	 <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>
	 <49656F01.3090603@pobox.com>  <49664FFD.1010608@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:39451 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757805AbZAHTZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:25:12 -0500
In-Reply-To: <49664FFD.1010608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-08 at 11:11 -0800, Rick Jones wrote:
> Jeff Garzik wrote:
> > Ben Hutchings wrote:
> >> The vetting of speeds is kind of silly.  Given that speed is established
> >> as being a number of Mbit/s (hence the need for speed_hi), why not
> >> remove the warning and the checks for known values and report it as
> >> such?
> > 
> > 
> > I'm ok with that route.  Historically it made sense, but AFAICS the 
> > driver _must_ verify the speed anyway, so removing the limitation in the 
> > userspace tool seems reasonable.
> > 
> > The next release of ethtool is coming in about 4 weeks, and we can 
> > definitely get something like this in there.
> 
> I have a simple patch which does just that ready to post, but will 
> point-out that removing the checks entirely will result in the speed 
> being reported as 65535 (without Unknown) for an interface with its 
> cable disconnected.  This however is is based only on "testing" on a 
> 2.6.24-22-generic (hardy) kernel with 7.3.20-k2-NAPI of the e1000 driver 
> driving an Intel 82566MM (rev 03).

I think 0, (u32)(-1) and (u16)(-1) may have to be special-cased as
unknown, but everything else can be treated as a number of Mbit/s.  I
don't know what a driver should do about an interface that really runs
at 65.535 Gbit/s though...

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

