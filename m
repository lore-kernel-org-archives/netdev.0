From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled (v2)
Date: Wed, 18 Jun 2008 01:52:06 -0700 (PDT)
Message-ID: <20080618.015206.22767411.davem@davemloft.net>
References: <20080617.170718.260234361.davem@davemloft.net>
	<396556a20806171745k63bb3516s5971593ecf216bc4@mail.gmail.com>
	<20080618023446.aba6516c.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agl@imperialviolet.org, netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40212
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751270AbYFRIwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 04:52:07 -0400
In-Reply-To: <20080618023446.aba6516c.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Wed, 18 Jun 2008 02:34:46 -0400

> I am not particularly familiar with the TCP MD5 option, but in googling
> around I found the following at the end of Section 2.2 Transmission,
> of RFC 4808, "TCP-MD5 Key Change", dated March 2007:
> 
>     "Note that there is an ambiguity when an acknowledgment is received
>     for a segment transmitted with two different keys.  The TCP Timestamp
>     option [RFC1323] can be used for disambiguation."
> 
> This would seem to imply, that at least in some scenarios, it would be
> advisable to have TS enabled in conjunction with MD5.

That does change the situation a bit, yes.

It's pretty easy, depending upon the timestamp resolution, to
end up with the original transmit and the retransmit having
the same timetsamp value.  So this suggestion in the RFC is
I think not a complete solution.
