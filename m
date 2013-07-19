From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: buggy check in netlink_mmap_sendmsg()
Date: Fri, 19 Jul 2013 16:45:56 +0100
Message-ID: <20130719154556.GF4165@ZenIV.linux.org.uk>
References: <20130714093619.GH4165@ZenIV.linux.org.uk>
 <20130718111358.GA27488@macbook.localnet>
 <20130719153846.GB14764@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54549 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615Ab3GSPp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 11:45:57 -0400
Content-Disposition: inline
In-Reply-To: <20130719153846.GB14764@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 19, 2013 at 05:38:46PM +0200, Patrick McHardy wrote:

> >From what I can tell, the second check should catch the second case you
> describe. If the address space is shared, dup_mmap() will invoke
> netlink_mmap_ops->open

See the check for CLONE_VM in copy_mm(); we do not call dup_mm() (which would
be calling dup_mmap()) in that case.
