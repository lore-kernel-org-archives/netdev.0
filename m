From: David Miller <davem@davemloft.net>
Subject: Re: Interface proposal for rx classification using ethtool
Date: Wed, 15 Oct 2008 16:19:15 -0700 (PDT)
Message-ID: <20081015.161915.153810861.davem@davemloft.net>
References: <48E11027.3060400@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	Matheos.Worku@Sun.COM
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40131
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752953AbYJOXTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 19:19:39 -0400
In-Reply-To: <48E11027.3060400@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona.Behera@Sun.COM
Date: Mon, 29 Sep 2008 10:28:07 -0700

> Here is the proposed design for implementing an interface to add, delete and
> manage rules for RX packet classification on ethertool with niu as the first
> target hardware. This is the second installment of network flow classification
> support (the first one was for rx flow distribution based on hashing that was
> added in June). Please review and send your feedback.

This looks mostly fine to me, thanks for working on this.

I do have one question though.

At least to some extent the user will have to have a way to
figure out that multiple interfaces correspond to one instance
of the TCAM.  Because this determines sharing and other
aspects, right?

How it seems to work in your description is that the user operates on
(for example) eth0 and eth1 as if they were independant objects, but
if the TCAM fills up that will be seen equally by operations on both
interfaces.

But, to be honest this is a minor detail.

They may also be value in allowing TCAM entries to be locked by the
kernel and thus be unmodifyable by the user.

For example, in NIU, those special workaround entries we add to handle
IP fragments would be a candidate for this.
