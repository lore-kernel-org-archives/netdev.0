From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: reflect the fwmark for replies with no socket
Date: Tue, 11 Mar 2014 22:52:39 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1403112242190.1769@ja.home.ssi.bg>
References: <1394536541-25702-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53626 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755614AbaCKUxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 16:53:21 -0400
In-Reply-To: <1394536541-25702-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 11 Mar 2014, Lorenzo Colitti wrote:

> Kernel-originated IP packets that have no user socket associated
> with them (e.g., ICMP errors and echo replies, TCP RSTs, etc.)
> are emitted with a mark of zero. Instead, make them have the
> same mark as the packet they are replying to.
> 
> This is consistent with TOS, which is also reflected from the
> incoming packet, and it allows the administrator to use
> mark-based routing, firewalling, etc. for these replies by
> marking the original packets inbound.

	If you can do it with CONNMARK save+restore,
do not change behavior for existing setups. It is
hard to predict how the mark is used in ip and
POST ROUTING rules.

> Also fix the IPv6 code to reflect the tclass in replies like the
> IPv4 code does.

Regards

--
Julian Anastasov <ja@ssi.bg>
