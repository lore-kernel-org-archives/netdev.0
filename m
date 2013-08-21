From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 0/2] fix generic netlink locking issue(s)
Date: Wed, 21 Aug 2013 21:05:43 +0200
Message-ID: <52150F87.90207@hartkopp.net>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:63234 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab3HUTGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 15:06:13 -0400
In-Reply-To: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.08.2013 16:08, Johannes Berg wrote:
> Here's another attempt at fixing the genetlink locking issue,
> hopefully better tested this time. Sorry about the mess the 
> previous version caused.
> 
> I really didn't find a way to "simply" add locking, no matter
> which way I turn genetlink is special because it would then use
> the same locks "inside" and "outside" the generic netlink family;
> "inside" because I'm trying to protect the otherwise unlocked
> dump call, and "outside" because it itself is a generic netlink
> family so needs to protect things there.
> 
> As a result, I've turned to RCU and (hopefully) made it safe.
> The unregistration can get fairly expensive with all the calls
> to synchronize_rcu(), but I don't see any better way, and it's
> hopefully really rare.
> 
> The only place that now uses RCU is ctrl_dumpfamily(), but it'd
> be possible to use it in other places. I didn't want to do it
> in this patch, but I also don't see any candidates where that 
> would really make sense. 
> 
> The first patch should obviously go into 3.11, I'll let you 
> decide about the second. This one might actually be easier to
> backport than the original one, but it'd still have to be done
> carefully.

I applied both patches.
The lockdep issue vanished and i still can write emails :-)

Thanks Johannes.

Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>


> 
> johannes
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
