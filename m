From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] napi: adding an administrative state & priority
Date: Wed, 23 Jul 2008 20:01:47 -0700 (PDT)
Message-ID: <20080723.200147.156146319.davem@davemloft.net>
References: <20080723192548.GA14654@hmsreliant.think-freely.org>
	<20080723.141158.99031196.davem@davemloft.net>
	<20080724012115.GA17150@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751190AbYGXDBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 23:01:47 -0400
In-Reply-To: <20080724012115.GA17150@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 23 Jul 2008 21:21:15 -0400

> And what are your thoughts regarding the creation of a napi instance priority
> scheme?  I understand your arguments for not disabling napi entirely, but it
> doesn't speak to prioritization.  I can still see a benefit to instructing the
> kernel to serve a interface first handling high priority traffic.

The weight assigned to each NAPI instance to some extent already
behaves much like a priority.

We could also do something like, knowing how many NAPI contexts
are scheduled, create a total work budget for an entire pass.

Each "weight" (you say "priority") assigned to the NAPI context
determines how big a slice of the pie that NAPI context gets.

But, two points:

1) True prioritization is the antithesis of what NAPI is trying
   to achieve.  It wants fairness and to avoid starvation.

2) %99.999999 of the time only a single NAPI context is scheduled
   on a cpu at a time, making this whole idea quite moot in my
   opinion :-)
