From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/20] net: NETDEV_UNREGISTER_PERNET ->
 NETDEV_UNREGISTER_BATCH
Date: Mon, 30 Nov 2009 14:49:17 -0800 (PST)
Message-ID: <20091130.144917.233710214.davem@davemloft.net>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, dlezcano@fr.ibm.com,
	adobriyan@gmail.com, kaber@trash.net, opurdila@ixiacom.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752201AbZK3WtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 17:49:11 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Sun, 29 Nov 2009 17:45:58 -0800

> Additionally it appears that we moved the route cache flush after
> the final synchronize_net, which seems wrong and there was no
> explanation.  So I have restored the original location of the final
> synchronize_net.

I think the idea was that it's important for all pending stale
RCU references to the device to be gone before we send out the
notifier.  And that's why the synchronize_net() comes first.

This needs more thought.
