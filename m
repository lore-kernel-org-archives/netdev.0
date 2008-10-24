From: David Miller <davem@davemloft.net>
Subject: Re: Regression: Recent networking (qdisc?) patches break
 irda_get_next_speed()
Date: Thu, 23 Oct 2008 17:21:29 -0700 (PDT)
Message-ID: <20081023.172129.179937745.davem@davemloft.net>
References: <20081021.164121.257737412.davem@davemloft.net>
	<48FFC438.1080505@ceibo.fiec.espol.edu.ec>
	<F169D4F5E1F1974DBFAFABF47F60C10A069DFD1F@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avillaci@ceibo.fiec.espol.edu.ec, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752127AbYJXAVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 20:21:52 -0400
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A069DFD1F@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Thu, 23 Oct 2008 15:13:02 -0700

> Isn't this what the data that is skb_reserve'd at the beginning of
> skb's allocated by netdev_alloc_skb is for?  If you take an extra
> reference to the skb and/or use a destructor hook you should be
> good, right?
>
> you should just be able to push ->data using skb_reserve(sizeof your
> private data) in the beginning of the skb, or is that a horrible
> idea Dave?

This area of the SKB data is still volatile.

Let's say a packet scheduler classifier causes a TC action
to execute which pushes stuff there, it'll get overwritten.

Really, this idea won't work.
