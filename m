From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] dev->refcnt long term holder
Date: Tue, 17 Nov 2009 09:58:46 -0800
Message-ID: <20091117095846.6ef8b4f6@nehalam>
References: <4B019381.2010509@gmail.com>
	<20091116110207.08b60c81@nehalam>
	<4B01ADF5.8090904@gmail.com>
	<20091117.003019.196504832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38629 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637AbZKQR6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 12:58:51 -0500
In-Reply-To: <20091117.003019.196504832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 00:30:19 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> I'm trying to remember why we added this asynchronous link state event
> processing monster.  It probably has something to do with needing a
> sleepable context.  What's amusing is that linkwatch has repeatably
> caused RTNL deadlock issues over the years. :-)

I thought it was to handle:
 1) carrier on old devices would bounce, so it provides ratelimiting
    of state changes. Modern hardware and CPU's probably makes this a non-issue.
 2) wasn't there some code path with device changes, hotplug, uevent and
    udev that meant that we couldn't do notifiers immediately.

-- 
