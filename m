From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses
 dev_addr_list
Date: Wed, 15 Apr 2009 03:45:07 -0700 (PDT)
Message-ID: <20090415.034507.208815568.davem@davemloft.net>
References: <49E5B365.2010008@trash.net>
	<20090415.031510.162624644.davem@davemloft.net>
	<49E5B9BD.5070204@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jpirko@redhat.com, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, mschmidt@redhat.com,
	ivecera@redhat.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756962AbZDOKpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:45:16 -0400
In-Reply-To: <49E5B9BD.5070204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 15 Apr 2009 12:41:01 +0200

> Herbert (I think) suggested to make address list updates in softirq
> context a two-step process, where addresses would first be added to
> a temporary list and the final change would be done in process context
> while holding the RTNL.
> 
> Given the complicated mess we currently have, this would be a very
> worthwhile change IMO.

This would break the IPV6 TAHI tests if you think we could use
such an idea for that.

When IPV6 packets arrive that influence multicast and unicast
address lists, the effect must be essentially immediate.  Such
that a subsequent packet will cause the kernel the behave
with the necessary side effects, no matter how quickly that
next packet arrives.
