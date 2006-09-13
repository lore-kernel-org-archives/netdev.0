From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] Alternate WE-21 support (core API)
Date: Wed, 13 Sep 2006 08:17:36 +0200
Message-ID: <1158128256.2894.8.camel@ux156>
References: <1157031138.16040.17.camel@ux156>
	 <20060831135112.GA6097@jm.kir.nu> <1157032805.16040.21.camel@ux156>
	 <20060906205538.GA29767@tuxdriver.com>
	 <20060906213053.GA21719@bougret.hpl.hp.com>
	 <20060908142913.GD23852@tuxdriver.com>
	 <20060908161345.GA27036@bougret.hpl.hp.com> <1157965694.2811.3.camel@ux156>
	 <20060911162608.GA31459@bougret.hpl.hp.com>
	 <1158050637.2854.16.camel@ux156> <20060912161737.GB3536@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:19872 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751612AbWIMGQz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 02:16:55 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060912161737.GB3536@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-12 at 09:17 -0700, Jean Tourrilhes wrote:

> 	I was initially very negative towards the WPA API (WPA +
> extended scan), because it's so complex. I went back and forth with
> Jouni trying to simplify it, but we did not manage to gain much. I
> trust that Jouni did the best he could, that's just the nature of the
> beast.

:)

> 	I was thinking of the WE -> nl80211 compatibility. It's pretty
> trivial to do as far as WE is concerned, you just need to hack
> get_handler() to return the nl80211 handler. Or, if you don't like a
> single handler, you could have one wrapper per ioctl, which is even
> easier.

Currently, I don't rely on that at all, nl80211 relies on the
driver/stack assigning ieee80211_ptr in the netdevice field and uses
that as a cookie. IOW, get_handler() gets to die.

My current plan for compatibility was to make all drivers cfg80211-away
by making them register themselves with cfg80211 with a callback struct
with entries for each thing they need to handle, and then introduce a
translation layer that translates incoming WE requests into the
appropriate callbacks just like nl80211 translates the incoming
genetlink messages.

> 	Do you have a recent version of your code so that I can see
> how it can hook on your side ? I think we could put the generic
> mechanism in place early so that people can add specifics as they need
> them.

The latest patches were posted to netdev quite a while ago, I haven't
done anything with them recently.

One thing I'd like to do is rename the include from net/nl80211.h to
net/cfg80211.h so that it's more obvious that it isn't purely netlink
(include/nl80211.h is the userspace netlink interface so that stays).

johannes
