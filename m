From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Thu, 01 Mar 2012 22:16:43 -0500 (EST)
Message-ID: <20120301.221643.881299898523907213.davem@davemloft.net>
References: <20120302025554.GA13493@joana>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johan.hedberg@gmail.com, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: gustavo@padovan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756744Ab2CBDRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 22:17:50 -0500
In-Reply-To: <20120302025554.GA13493@joana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo Padovan <gustavo@padovan.org>
Date: Thu, 1 Mar 2012 23:55:55 -0300

>  - I'm pulling directly to you because due to the coding style issues that
>    happened some days ago. We decided, after talk to John, to pull directly to
>    you, so you can take a look before pull. I personally looked to the whole
>    diff of this pull request and couldn't spot anything that doesn't seem
>    specified in CodingStyle.

For the members of "struct inquiry_cache" the tabbing has been all
messed up by commit 561aafbcb2e3f8fee11d3781f866c7b4c4f93a28.

Instead of all of the member names being nicely aligned using tabs it now
looks like (after all the commits it's now called "struct discovery_state"):

	int type;
	enum {
		DISCOVERY_STOPPED,
		DISCOVERY_STARTING,
		DISCOVERY_FINDING,
		DISCOVERY_RESOLVING,
		DISCOVERY_STOPPING,
	} state;
	struct list_head all;		/* All devices found during inquiry */
	struct list_head unknown;	/* Name state not known */
	struct list_head resolve;	/* Name needs to be resolved */
	__u32		timestamp;

instead of something more reasonable like:

	int			type;
	enum {
		DISCOVERY_STOPPED,
		DISCOVERY_STARTING,
		DISCOVERY_FINDING,
		DISCOVERY_RESOLVING,
		DISCOVERY_STOPPING,
	} state;
	struct list_head	all;		/* All devices found during inquiry */
	struct list_head 	unknown;	/* Name state not known */
	struct list_head 	resolve;	/* Name needs to be resolved */
	__u32			timestamp;

The person editing this had to go out of their way to make things like this
way.

This was only three commits into your tree, therefore I'm not very
optimistic to be honest with you.
