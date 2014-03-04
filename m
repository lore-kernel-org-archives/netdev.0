From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Tue, 04 Mar 2014 17:20:25 -0500 (EST)
Message-ID: <20140304.172025.2034977449200344617.davem@davemloft.net>
References: <1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<20140304.170050.2058599034902221847.davem@davemloft.net>
	<cc9ba7943aebff9ba87b60778b62f1a8.squirrel@webmail.itwm.fhg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbaCDWU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 17:20:27 -0500
In-Reply-To: <cc9ba7943aebff9ba87b60778b62f1a8.squirrel@webmail.itwm.fhg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Date: Tue, 4 Mar 2014 23:16:31 +0100

> I see some value in being able to memcpy() to/from those fields directly
> when building/reading headers, but I also think that not having to do
> endianness conversion everywhere for a struct that cannot ever be a valid
> header as is outweighs this.

Why have an intermediate copy when that's not necessary at all?  It
seems like pure overhead to be.

Furthermore, cpu's have byte-shifting load and store instructions
which will be used if you make use of the 'p' versions of the endian
swap functions, such as cpu_to_le16p().

So it's going to cost basically nothing.
