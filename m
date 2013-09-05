From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu, 05 Sep 2013 14:17:51 -0400 (EDT)
Message-ID: <20130905.141751.945639989861997124.davem@davemloft.net>
References: <1378402887-17331-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, azhou@nicira.com,
	fengguan.wu@intel.com, geert@linux-m68k.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818Ab3IESRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:17:55 -0400
In-Reply-To: <1378402887-17331-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu,  5 Sep 2013 10:41:27 -0700

> -} __aligned(__alignof__(long));
> +} __aligned(8); /* 8 byte alignment ensures this can be accessed as a long */

This kind of stuff drives me crazy.

If the issue is the type, therefore at least use an expression that
mentions the type explicitly.  And mention the actual type that
matters.  "long" isn't it.

These half-hearted attempts to fix this problem are just papering
around the issue and do not address the real issue directly.

I don't want to apply changes like this.

You don't want "8 byte alignment", you want the alignment necessary
for the types contained in the structure to be accessed without
generating exceptions.  You might also want the "quickest" alignment,
and there are ways to express that as well.

This structure doesn't even contain a "long".  "long" isn't even
64-bit on some architectures, and you certainly have 64-bit types in
this thing (__be64).

Let's start from the beginning, what are you actually trying to
accomplish here that isn't handled automatically by the compiler
already?

Is it "proper" alignment?  That is handled automatically by the
compiler.  Is it "fast" alignment?  In what context and in what ways
is that important in this specific case?
