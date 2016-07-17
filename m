From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6]NET:AX25:ROSE Adds device use count, adds trap to
 prevent kernel crash, plus other cleanup
Date: Sat, 16 Jul 2016 22:15:49 -0700 (PDT)
Message-ID: <20160716.221549.671177541113968993.davem@davemloft.net>
References: <201607160940.u6G9exbE014395@ux4.g1sog>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: richard@rns-stearn.demon.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbcGQFPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 01:15:50 -0400
In-Reply-To: <201607160940.u6G9exbE014395@ux4.g1sog>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First, this is really a poorly formatted submission.

All of this:

====================
Subject: [PATCH 0/6]NET:AX25:ROSE Adds device use count, adds trap to prevent kernel crash, plus other cleanup
[PATCH 1/6]NET:AX25:ROSE
Adds device use count for core of protocol.
====================

over and over is not what belongs in this "0/6" header postings.

Instead, you're supposed to write paragraphs of prose, explaining to us what
this patch series is doing, how it is doing it, and why it is doing it that way.

Next, the Subject lines should be of the form:

	"[PATCH N/M] ax25: ..."

Note the spaces, and the subsystem prefix is in lowercase letters, and we typically
don't use a cascade of "x: y: z:", it's just pointless.

Also, do not duplicate the Subject line in your commit log messages.

Second of all, all of these new device refcount bumps create a new problem.
You can't just do get and put all over the place.

You also have to have device notifiers that kill all of the ax25/rose
objects that point to the device when someone tries to unregister it.
