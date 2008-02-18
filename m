From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Support arbitrary initial TCP timestamps
Date: Sun, 17 Feb 2008 23:33:30 -0800 (PST)
Message-ID: <20080217.233330.157255657.davem@davemloft.net>
References: <1203097630-13237-1-git-send-email-ggriffin.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ggriffin.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753795AbYBRHcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 02:32:53 -0500
In-Reply-To: <1203097630-13237-1-git-send-email-ggriffin.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Glenn Griffin <ggriffin.kernel@gmail.com>
Date: Fri, 15 Feb 2008 09:47:08 -0800

> Introduce the ability to send arbitrary initial tcp timestamps that are not
> tied directly to jiffies.  The basic conecpt is every tcp_request_sock and
> tcp_sock now has a ts_off offset that represents the difference between
> tcp_time_stamp and the timestamp we send and expect to
> receive.
> 
> This has the advantage of not divulging system information (uptime)
> depending on the policy chosen for the initial timestamps.
> 
> A policy where ts_off is always set to zero should produce no change in
> behavior.  The policy implemented is not intended for real use, but just as
> a simple example.  A realistic example would probably be similar to the tcp
> init sequence generator.
> 
> Signed-off-by: Glenn Griffin <ggriffin.kernel@gmail.com>

Adding yet another member to the already bloated tcp_sock structure to
implement this is too high a cost.

I would instead prefer that there be some global random number
calculated when the first TCP socket is created, and use that as a
global offset.  You can even recompute it every few hours if you
like.

We do similar things already elsewhere.
