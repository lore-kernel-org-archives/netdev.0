From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: pktgen question
Date: Sun, 23 Sep 2007 21:28:04 +0400
Message-ID: <20070923172803.GA11997@2ka.mipt.ru>
References: <46F6905C.6030309@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37649 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbXIWSEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2007 14:04:48 -0400
Content-Disposition: inline
In-Reply-To: <46F6905C.6030309@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steve.

On Sun, Sep 23, 2007 at 11:12:12AM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
> The pktgen module provides a way to "clone" the skb its using for 
> transmission, and allows passing N clones of the originally created skb 
> to the driver under test.    However, it doesn't really use skb_clone(), 
> but rather it just bumps the skb->users count for each "clone" and 
> passes the same skb ptr to the driver.
> 
> Q: Is that a valid use of skb->users or should pktgen really be cloning 
> the skbuff?

It's a hack, but since skb is owned by pktgen only (no copies in some
outside queues or some other access) it is allowed just to bump reference
counter (i.e. 'share' skb in usual notation).

-- 
	Evgeniy Polyakov
