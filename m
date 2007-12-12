From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: napi fix
Date: Wed, 12 Dec 2007 09:38:19 -0800 (PST)
Message-ID: <20071212.093819.205755031.davem@davemloft.net>
References: <47601A73.5010804@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51657
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751711AbXLLRiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 12:38:20 -0500
In-Reply-To: <47601A73.5010804@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 12 Dec 2007 12:29:23 -0500

> Is the netif_running() check even required?

No, it is not.

When a device is brought down, one of the first things
that happens is that we wait for all pending NAPI polls
to complete, then block any new polls from starting.
