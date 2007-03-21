From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] [NETLINK]: Ignore control messages directly in netlink_run_queue()
Date: Wed, 21 Mar 2007 13:06:23 +0100
Message-ID: <46011FBF.90409@trash.net>
References: <20070321001810.616784269@lsx.localdomain> <20070321001900.885191779@lsx.localdomain> <4600B828.1050801@trash.net> <20070321114522.GR521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41128 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659AbXCUMGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 08:06:36 -0400
In-Reply-To: <20070321114522.GR521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2007-03-21 05:44
> 
>>This looks like it would break nfnetlink, which appears to be
>>using 0 as smallest message type.
> 
> 
> It shouldn't do that, the first 16 message types are reserved
> for control messages.


I'm afraid it does:

enum cntl_msg_types {
        IPCTNL_MSG_CT_NEW,
        IPCTNL_MSG_CT_GET,
        IPCTNL_MSG_CT_DELETE,
        IPCTNL_MSG_CT_GET_CTRZERO,
        IPCTNL_MSG_MAX
};

This is totally broken of course since it also uses netlink_ack(),
netlink_dump() etc. :( Any smart ideas how to fix this without
breaking compatibility?

