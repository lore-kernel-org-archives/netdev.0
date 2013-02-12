From: David Miller <davem@davemloft.net>
Subject: Re: bridge interface initial carrier state
Date: Tue, 12 Feb 2013 16:10:31 -0500 (EST)
Message-ID: <20130212.161031.1842795886962716008.davem@davemloft.net>
References: <1360612915.8633.6.camel@dcbw.foobar.com>
	<20130211135836.2220ca68@nehalam.linuxnetplumber.net>
	<20130212210605.GA28929@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, dcbw@redhat.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab3BLVKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 16:10:33 -0500
In-Reply-To: <20130212210605.GA28929@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 Feb 2013 22:06:05 +0100

> Mon, Feb 11, 2013 at 10:58:36PM CET, stephen@networkplumber.org wrote:
>>On Mon, 11 Feb 2013 14:01:55 -0600
>>Dan Williams <dcbw@redhat.com> wrote:
>>
>>> Hi,
>>> 
>>> I'm wondering if the initial carrier state of 'on' is intentional for a
>>> bridge without ports; immediately after adding ports, the carrier is
>>> recalculated and depends on the combined state of each port's carrier
>>> and STP forwarding state.  So a userspace program attempting to decide
>>> whether the bridge was usable or not has to look at both (a) how many
>>> ports are available and (b) bridge carrier state, instead of just
>>> looking at the bridge carrier state.
>>> 
>>> Dan
>>
>>It really should be off when no ports are present, but some initial startup
>>scripts broke when it was that way.
> 
> How so? Can you give me an example of that script?
> I think that any script should be able to handle a situation when carrier
> of some device is down...

These are scripts that are looking for interfaces that are "active".
The definition of this for layered and software devices is very
ambiguous, therefore the only sane thing to do is to default to
having the carrier on by default.
