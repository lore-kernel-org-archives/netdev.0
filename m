From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BNX2X] round three
Date: Mon, 15 Oct 2007 12:38:50 -0700 (PDT)
Message-ID: <20071015.123850.26516814.davem@davemloft.net>
References: <p73641c4cfz.fsf@bingen.suse.de>
	<20071012.150341.41635825.davem@davemloft.net>
	<1192462049.29746.158.camel@eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org, jeff@garzik.org,
	mchan@broadcom.com
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55671
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753975AbXJOTiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 15:38:46 -0400
In-Reply-To: <1192462049.29746.158.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Mon, 15 Oct 2007 17:27:29 +0200

> Unfortunately, the firmware code is different for LE and BE machines.
> We had issues with the BE firmware that appear to be resolved.
> Hopefully, the next version will have both.

If this means we get two copies of the firmware, this should be
rethought.  The space cost of the firmware (both in terms of source
code size and object code size) is already enormous.

I would definitely prefer if there were only little-endian firmware,
and the driver uses "cpu_to_le32()" and friends to access chip shared
data structures.

Most cpus have endian swapping loads and stores, accessible via
cpu_to_le32p() and similar interfaces, so the cost on big-endian of
doing things this way is very close to zero.
