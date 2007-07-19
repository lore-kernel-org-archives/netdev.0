From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 issues
Date: Thu, 19 Jul 2007 10:34:25 -0700
Message-ID: <1184866465.10854.45.camel@dell>
References: <469E78A2.80904@imperialnet.org>
 <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com>
 <20070719113755.GA1934@hmsreliant.homelinux.net>
 <469F6601.20800@imperialnet.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Neil Horman" <nhorman@tuxdriver.com>,
	"netdev" <netdev@vger.kernel.org>
To: "patric" <pakar@imperialnet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4790 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760591AbXGSQlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 12:41:39 -0400
In-Reply-To: <469F6601.20800@imperialnet.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-19 at 15:24 +0200, patric wrote:

> 
> Just a hypothetical question. If the 2 network cards starts the 
> autonegotiation would it be possible that they get into a loop where 
> they are chasing each others state?  Maybe a fix could be to add a sleep 
> of a random length that would enable them to catch up? Maybe you know if 
> any of the fiber-cards so support running without flowcontrol too since 
> the cards don't seem to be able to get a link with flowcontrol turned 
> off at least in this setup.
> 
> 

The old 5701 fiber NICs do not support autonegotiation in hardware so it
is done "by hand" in the driver.  It is not the most robust way of doing
autoneg and what you described is totally possible.  You might want to
try disabling autoneg to see if it works any better.  There is only one
possible speed in fiber and autoneg is really only used to negotiate
flow control.  Some switch ports will not link up if the link partner
does not do autoneg though.

You have to use ethtool in initrd to turn off autoneg or just modify the
driver to disable autoneg.

