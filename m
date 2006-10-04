From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Wed, 04 Oct 2006 18:31:17 +0200
Message-ID: <4523E1D5.1060505@web.de>
References: <4523DA7D.2080604@web.de> <200610041807.05266.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:60092 "EHLO
	fmmailgate02.web.de") by vger.kernel.org with ESMTP
	id S1161566AbWJDQdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 12:33:13 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610041807.05266.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ivo van Doorn wrote:
> Hi,
> 
>> Ivo told me about a patch for d80211 that moved certain timers to thread
>> context, effectively avoiding to call config from timer handlers, but I
>> didn't find any trace yet. Is there some modification in this direction
>> already scheduled? I'm not necessarily looking for work, at best I would
>> just enjoy to use it. ;)
> 
> I have found the actual patch:
> [PATCH 1/5] d80211: make sleeping in hw->config possible
> And was send on august 1st by Jiri to the netdev list.
> It was based on a patch by Michael Buesch.

Ah, looks like I didn't dug thoroughly enough.

Anyway, this means my BUG proved the patch's claim wrong :o), at least
one atomic gremlin is left:

ieee80211_sta_timer ->
ieee80211_sta_find_ibss ->
ieee80211_sta_join_ibss ->
ieee80211_ioctl_siwfreq ->
ieee80211_hw_config

Anyone already an idea how to fix it?

Jan
