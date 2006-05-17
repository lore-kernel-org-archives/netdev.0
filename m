From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Wed, 17 May 2006 15:36:20 -0700
Message-ID: <adairo446u3.fsf@cisco.com>
References: <20060517220218.GA13411@myri.com>
	<20060517220608.GD13411@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:27548 "EHLO
	sj-iport-5.cisco.com") by vger.kernel.org with ESMTP
	id S1750797AbWEQWgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 18:36:22 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <20060517220608.GD13411@myri.com> (Brice Goglin's message of "Wed, 17 May 2006 18:06:10 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Still some suspicious uses of volatile here.

For example:

> +struct myri10ge_priv {
 ...
> +	volatile u8 __iomem *sram;

as far as I can see this is always used with proper __iomem accessors,
often with casts to strip the volatile anyway.  So why is volatile needed?

I would suggest an audit of all uses of volatile in the driver, since
"volatile" in drivers really should be read "there's probably a bug
here, and if not something very tricky is going on."  If there are any
valid uses of volatile then a comment should explain why, so that
future reviewers don't have to try and puzzle out which of the
two possible translations of volatile is correct.

 - R.
