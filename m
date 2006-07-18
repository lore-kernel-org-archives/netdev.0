From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 14:20:16 -0700 (PDT)
Message-ID: <20060718.142016.124082348.davem@davemloft.net>
References: <20060718115125.GA6087@2ka.mipt.ru>
	<200607181436.57841.borntrae@de.ibm.com>
	<20060718191137.GB28540@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: borntrae@de.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30661
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932074AbWGRVTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 17:19:53 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060718191137.GB28540@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 18 Jul 2006 23:11:37 +0400

> Actually userspace will not see ERESTARTSYS, when it is returned from
> syscall.

This is true only when a signal is pending.

It is the signal dispatch code that fixes up the return value
either by changing it to -EINTR or by resetting the register
state such that the signal handler returns to re-execute the
system call with the original set of argument register values.

If a signal is not pending, you risk leaking ERESTARTSYS to
userspace.
