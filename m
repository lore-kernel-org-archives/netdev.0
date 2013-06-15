From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sat, 15 Jun 2013 20:38:01 +0200
Message-ID: <1371321481.8319.7.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130612230257.GB21234@electric-eye.fr.zoreil.com>
	 <1371160342.8335.22.camel@jlt4.sipsolutions.net>
	 <20130613230341.GB16632@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:55625 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718Ab3FOSiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 14:38:06 -0400
In-Reply-To: <20130613230341.GB16632@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-14 at 01:03 +0200, Francois Romieu wrote:
> Johannes Berg <johannes@sipsolutions.net> :
> [...]
> > Yes, I suppose I could, but is it worth it? It's held only for a very
> > short amount of time to get the indirect register access correct. I
> > don't really see any reason to prefer a mutex here?
> 
> Neither a spinlock nor a mutex should be needed but I have to sleep
> before figuring it.

I totally think you're right, I'm just not a big fan of making the
locking difficult to understand :-)

OTOH, I could stick an ASSERT_RTNL() in there and not worry about it.
I'm fairly sure that everything here is under rtnl (work struct I lock
myself, configuration ops will be, and ethtool should be too ...) but
does removing that lock really make the driver better? I'm not really
sure about that.

johannes
