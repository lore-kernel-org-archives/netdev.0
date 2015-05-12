From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 00/24] switchdev: spring cleanup
Date: Tue, 12 May 2015 18:45:32 -0400 (EDT)
Message-ID: <20150512.184532.1368324454021599990.davem@davemloft.net>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933352AbbELWph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 18:45:37 -0400
In-Reply-To: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sun, 10 May 2015 09:47:45 -0700

> The main theme of this patch set is to cleanup swdev in preparation for
> new features or fixes to be added soon.  We have a pretty good idea now how
> to handle stacked drivers in swdev, but there where some loose ends.  For
> example, if a set failed in the middle of walking the lower devs, we would
> leave the system in an undefined state...there was no way to recover back to
> the previous state.  Speaking of sets, also recognize a pattern that most
> swdev API accesses are gets or sets of port attributes, so go ahead and make
> port attr get/set the central swdev API, and convert everything that is
> set-ish/get-ish to this new API.
> 
> Features/fixes that should follow from this cleanup:
> 
>  - solve the duplicate pkt forwarding issue
>  - get/set bridge attrs, like ageing_time, from/to device
>  - get/set more bridge port attrs from/to device
> 
> There are some rename cleanups tagging along at the end, to give swdev
> consistent naming.
> 
> And finally, some much needed updates to the switchdev.txt documentation to
> hopefully capture the state-of-the-art of swdev.  Hopefully, we can do a better
> job keeping this document up-to-date.
> 
> Tested with rocker, of course, to make sure nothing functional broke.  There
> are a couple minor tweaks to DSA code for getting switch ID and setting STP
> updates to use new API, but not expecting amy breakage there.

Ok, this series looks good for the most part so I'll apply it, thanks
Scott.

One thing that worries me is that deferral of operations when rtnl
isn't held.  You've lost the ability there to signal an error back
to the user, so you just return zero and BUG() if it does actually
error.

You'll need to do something better in that situation in my opinion.

My preference would be to require that RTNL is held on any traversal
into those code paths.
