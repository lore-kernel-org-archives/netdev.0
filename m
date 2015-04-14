From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 15/17] switch kernel_sendmsg() and kernel_recvmsg() to
 iov_iter_kvec()
Date: Tue, 14 Apr 2015 17:34:03 +0100
Message-ID: <20150414163403.GY889@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
 <1428787108-13650-15-git-send-email-viro@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1CB1DD9D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59913 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932935AbbDNQeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 12:34:08 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1DD9D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2015 at 04:21:02PM +0000, David Laight wrote:

> Massive NAK.
> This breaks any code that is using msg_control to set SCTP parameters
> when sending data.

	Huh?  ->sendmsg() expects ->msg_control already in kernel space;
it's ->recvmsg() that plays silly buggers with userland pointers there.
