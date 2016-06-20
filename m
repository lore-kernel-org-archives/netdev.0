From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] net:ppp: replace too strict capability restriction on opening  /dev/ppp
Date: Sun, 19 Jun 2016 22:02:02 -0700
Message-ID: <87wplkihbp.fsf@tassilo.jf.intel.com>
References: <44A9BDB8-754B-4402-BD09-6381229C07C5@tuna.tsinghua.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	Guillaume Nault <g.nault@alphalink.fr>,
	Miao Wang <shankerwangmiao@gmail.com>
To: Shanker Wang <shanker@tuna.tsinghua.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38220 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701AbcFTFCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 01:02:06 -0400
In-Reply-To: <44A9BDB8-754B-4402-BD09-6381229C07C5@tuna.tsinghua.edu.cn>
	(Shanker Wang's message of "Sun, 19 Jun 2016 01:38:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shanker Wang <shanker@tuna.tsinghua.edu.cn> writes:

> This patch removes the check for CAP_NET_ADMIN in the initial namespace
> when opening /dev/open. Instead, CAP_NET_ADMIN is checked in the user
> namespace the net namespace was created so that /dev/ppp cat get opened
> in a unprivileged container.

Seems dangerous. From a quick look at the PPP ioctl there is no limit
how many PPP devices this can create. So a container having access to
this would be able to fill all kernel memory. Probably needs more
auditing and hardening first.

In general there seems to be a lot of attack surface for root
in PPP.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
