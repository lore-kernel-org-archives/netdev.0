From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH -rt] Fix initialization of spinlock in irttp_dup()
Date: Wed, 21 Mar 2007 08:11:13 +0100
Message-ID: <20070321071113.GA5894@elte.hu>
References: <20070320192233.GA14543@plexity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	Daniel Walker <dwalker@mvista.com>
To: Deepak Saxena <dsaxena@plexity.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:51296 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932768AbXCUHLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 03:11:34 -0400
Content-Disposition: inline
In-Reply-To: <20070320192233.GA14543@plexity.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Deepak Saxena <dsaxena@plexity.net> wrote:

> This was found around the 2.6.10 timeframe when testing with the -rt 
> patch and I believe is still is an issue. irttp_dup() does a memcpy() 
> of the tsap_cb structure causing the spinlock protecting various 
> fields in the structure to be duped.  This works OK in the non-RT case 
> but in the RT case we end up with two mutexes pointing to the same 
> wait_list and leading to an OOPS. Fix is to simply initialize the 
> spinlock after the memcpy().

note that memcpy based lock initialization is a problem for lockdep too.

	Ingo
