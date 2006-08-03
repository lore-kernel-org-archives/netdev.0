From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 14:45:58 -0700 (PDT)
Message-ID: <20060803.144558.02298663.davem@davemloft.net>
References: <20060803163204.GB20603@thunk.org>
	<1154623598.19547.52.camel@c-67-188-28-158.hsd1.ca.comcast.net>
	<20060803171731.GE20603@thunk.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwalker@mvista.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mchan@broadcom.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030187AbWHCVqm@vger.kernel.org>
To: tytso@mit.edu
In-Reply-To: <20060803171731.GE20603@thunk.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Theodore Tso <tytso@mit.edu>
Date: Thu, 3 Aug 2006 13:17:31 -0400

> The tg3_timer() code, for example, is trigger by the device driver but
> isn't associated with a process for boosting purposes, and creating a
> process just so that tg3_timer() can be boosted seems like the Wrong

Ted please make sure the tg3 chips you have actually do need
that periodic poking code that tg3_timer() has, most chips do
not.

You don't need the periodic poke unless TG3_FLAG_TAGGED_STATUS is
cleared, and that is only the case for two chips 1) 5700 and 2) 5788.

The only thing left is the link status and that is not so concerned
about mild forms of latency in the timer firing.
