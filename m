From: jamal <hadi@cyberus.ca>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Wed, 17 Feb 2010 18:49:13 -0500
Message-ID: <1266450553.17794.165.camel@bigi>
References: <20100217191718.GA5256@x200>
	 <20100217.134217.244120118.davem@davemloft.net>
	 <1266449678.17794.160.camel@bigi>
	 <20100217.154009.78177059.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:38149 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756610Ab0BQXtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 18:49:16 -0500
Received: by qyk38 with SMTP id 38so2474952qyk.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 15:49:15 -0800 (PST)
In-Reply-To: <20100217.154009.78177059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 15:40 -0800, David Miller wrote:

> Please do, your changes are reverted so I need the whole
> thing back.

np.
Q: Something odd i noticed when looking at pfkey (different behavior
from netlink):

pfkey_sendmsg() does at the end:
return err ? : len;

So if err was 0, it will always return the length which is
16 in the flush which was causing the EAGAIN Alexey saw. If i returned
the correct error (ESRCH), it goes unfiltered.
It sounds to me that should just unconditionaly return err, no?

cheers,
jamal

