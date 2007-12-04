From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: when using arp monitoring with bonding, why use broadcast arps?
Date: Tue, 04 Dec 2007 10:20:56 -0800
Message-ID: <17022.1196792456@death>
References: <47558DFC.5050601@nortel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:33694 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbXLDSVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 13:21:14 -0500
In-reply-to: <47558DFC.5050601@nortel.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <cfriesen@nortel.com> wrote:
[...]
>Is there any particular reason why the bonding code couldn't use unicast
>arp packets if the "arp_ip_target" has a valid entry in the sender's arp
>table?

	It ought to be a pretty straightforward change to have the
bond_arp_send() function perform a neigh_lookup() prior to calling
arp_create(), and use the result of the lookup (if any) in the
arp_create() call.

	So, no, with the caveat that I haven't tried it, I don't see a
reason that bonding couldn't do what you're looking for.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
