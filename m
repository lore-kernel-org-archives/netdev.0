From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] netconsole: release the spinlock before
 __netpoll_cleanup()
Date: Wed, 06 Mar 2013 22:51:21 +0800
Message-ID: <1362581481.4435.23.camel@cr0>
References: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Neil Horman <nhorman@tuxdriver.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758527Ab3CFOve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 09:51:34 -0500
In-Reply-To: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-06 at 15:46 +0100, Veaceslav Falico wrote:
> Commit 3335f0ca130c201f8680e97f63612053fbc16e22 removed spinlock unlocking
> before __netpoll_cleanup() in netconsole_netdev_event(), however we still
> might sleep in __netpoll_cleanup() - via synchronize_srcu(). Revert it and
> add a comment.
> 

synchronize_srcu() was actually introduced by Neil:

commit ca99ca14c95ae49fb4c9cd3abf5f84d11a7e8a61
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Tue Feb 5 08:05:43 2013 +0000

    netpoll: protect napi_poll and poll_controller during dev_[open|
close]

Cc'ing him.
