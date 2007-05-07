From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Tue, 8 May 2007 02:19:53 +0530
Message-ID: <a781481a0705071349v145787cdgf4853cb40c73fbea@mail.gmail.com>
References: <m3abwhcy74.fsf@maximus.localdomain>
	 <Pine.LNX.4.64.0705071318150.1479@scrub.home>
	 <m3r6psc0ee.fsf@maximus.localdomain>
	 <Pine.LNX.4.64.0705071509290.1479@scrub.home>
	 <463F27CE.2040008@garzik.org>
	 <Pine.LNX.4.64.0705071538060.1479@scrub.home>
	 <m3lkg0a88y.fsf@maximus.localdomain>
	 <Pine.LNX.4.64.0705071901020.1479@scrub.home>
	 <a781481a0705071115v5bce9382q166b9c0e0c52c6ef@mail.gmail.com>
	 <463F8CB4.3040603@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Roman Zippel" <zippel@linux-m68k.org>,
	"Krzysztof Halasa" <khc@pm.waw.pl>,
	"Russell King" <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:6005 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966583AbXEGUty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 16:49:54 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1736542wra
        for <netdev@vger.kernel.org>; Mon, 07 May 2007 13:49:53 -0700 (PDT)
In-Reply-To: <463F8CB4.3040603@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/8/07, Jeff Garzik <jeff@garzik.org> wrote:
> Satyam Sharma wrote:
> > Yes, mixing select and depends is a recipe for build disasters. Call
> > me a rabid fanatic, but I would in fact go as far as to say that this
> > whole "select" thing in the Kconfig process is one big BUG, and not a
> > feature. People are lazy by nature and would rather just "select" a
> > dependency for their config option than burden users with several
> > "depends".
>
> Tough, the kernel community has voted against you.

Heh ... I guess I appeared a trifle _too_ fanatic there, but I'm not.
That rant against it was actually more about controlling its
{ab-,mis-}use and rampant proliferation (even to cases where it is
inapplicable / avoidable) than removing it altogether. Especially,
when a developer is lazy / wrong and mixes select and depends in the
same dependency chain leading to errors.

> It makes far more sense to include a driver during kernel configuration,
> and have that driver pull in its libraries via 'select'.  The lame
> alternative requires developers to know which libraries they need BEFORE
> picking their drivers, which is backwards and requires legwork on the
> part of the kernel developer.

(That bit about a developer _knowing_ which libraries to select
manually before selecting a driver is not really true, you can "?" on
a config item and get all its "depends" and "select" dependencies
anyway -- and it requires more leg work, yes, but then you'll never
have build failures either)

Still, I don't really disagree w.r.t. "select"ing libraries, as long
as we're careful to limit them to _only_ libraries.
