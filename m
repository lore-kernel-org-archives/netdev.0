From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 16/17] get rid of the size argument of sock_sendmsg()
Date: Tue, 14 Apr 2015 17:35:34 +0100
Message-ID: <20150414163534.GZ889@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
 <1428787108-13650-16-git-send-email-viro@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1CB1DDB2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59916 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932248AbbDNQfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 12:35:38 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1DDB2@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2015 at 04:25:24PM +0000, David Laight wrote:
> From: Al Viro
> > Sent: 11 April 2015 22:18
> > it's equal to iov_iter_count(&msg->msg_iter) in all cases
> 
> I don't know whether this is guaranteed for iov[] that come from
> userspace.
>
> In any case iov_iter_count() is non-trivial and you don't
> really want to call it when unnecessary.

Really?

static inline size_t iov_iter_count(struct iov_iter *i)
{
        return i->count;
}
