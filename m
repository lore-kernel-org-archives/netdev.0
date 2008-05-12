From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 15:31:14 -0700 (PDT)
Message-ID: <20080512.153114.163063885.davem@davemloft.net>
References: <d1c2719f0805072033u38dfffaes71aed3efbc8035c0@mail.gmail.com>
	<d1c2719f0805121522g4767f585h4b33790318f44264@mail.gmail.com>
	<20080512.152900.220913361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49394
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754007AbYELWbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 18:31:19 -0400
In-Reply-To: <20080512.152900.220913361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 12 May 2008 15:29:00 -0700 (PDT)

> Simply notice, when we're about to decrement in_flight, that the data
> reference is one.  You can take appropriate actions if so.

Actually, there is an even simpler solution.  Since this is a fast
clone, when the parent SKB is freed we can see if the fast-clone child
is active and has the in_flight atomic_t pointer.  If so, we decrement
in_flight and zap it to NULL.
