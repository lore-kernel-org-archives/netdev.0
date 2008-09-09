From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 08 Sep 2008 20:43:23 -0700 (PDT)
Message-ID: <20080908.204323.04156464.davem@davemloft.net>
References: <48C5E2FC.4090304@atheros.com>
	<20080908.194627.169864643.davem@davemloft.net>
	<20080909025525.GB25148@hostap.isc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jouni.malinen@atheros.com, alex.williamson@hp.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: j@w1.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47329
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752304AbYIIDnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 23:43:31 -0400
In-Reply-To: <20080909025525.GB25148@hostap.isc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jouni Malinen <j@w1.fi>
Date: Mon, 8 Sep 2008 19:55:25 -0700

> On Mon, Sep 08, 2008 at 07:46:27PM -0700, David Miller wrote:
> > This one breaks wireless with 32bit userspace/64bit kernel.  Bisected
> > back to changeset 087d833e5a9f67ba933cb32eaf5a2279c1a5b47c:
> > 
> > mac80211: Use IWEVASSOCREQIE instead of IWEVCUSTOM
> 
> Great.. I was hoping that the WEXT compat ioctl fixes from Dave resolved 
> all WEXT cases. This code is (and was) using wireless_send_event() and I 
> did not find clear changes to its use in Dave's patch set. Was that 
> supposed to be fixed with the compat ioctl patches? I'm not very 
> familiar with this area and don't have an easy way to test this now (I'm 
> traveling and don't have access to a 64/32-bit setup).

If we're talking about the netlink emission of WEXT blobs, then such
bits cannot be fixed unfortunately, because via netlink we don't know
in the message generating context what kind of process will receive
the message.

In fact, when broadcasting a netlink message, applications of different
dispositions can want to receive the message.

So in essence netlink cases cannot be fixed for COMPAT handling,
rather, netlink protocols must be designed to be COMPAT agnostic from
the beginning, and use fixed sized types only.  WEXT was not.

