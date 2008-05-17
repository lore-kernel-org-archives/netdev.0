From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 16 May 2008 18:29:33 -0700 (PDT)
Message-ID: <20080516.182933.242150078.davem@davemloft.net>
References: <d1c2719f0805122100u7e550820xff6fcdbc1e538948@mail.gmail.com>
	<20080512.210202.158182011.davem@davemloft.net>
	<d1c2719f0805161813kc0dca29y1feaf4d512a959e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37896
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751152AbYEQB3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 21:29:39 -0400
In-Reply-To: <d1c2719f0805161813kc0dca29y1feaf4d512a959e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Fri, 16 May 2008 18:13:20 -0700

> The host inflight accounting gets screwed up. It looks like
> pskb_expand_head() called by tcp_tso_acked()->tcp_trim_head() messes
> up the accounting but I don't know how to fix it (still trying to
> understand this complex piece of code). There could be other reason
> as well.

This is just like freeing up a normal SKB, so decrementing the
in_flight value the appropriate number of packets should do the right
thing.

tcp_tso_acked() calculates this adjustment for you, in packets_acked.
