From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] enic: fix issues in enic_poll
Date: Tue, 30 Jun 2015 23:56:55 -0700 (PDT)
Message-ID: <20150630.235655.1007982516718911399.davem@davemloft.net>
References: <1435730034-18284-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130AbbGAG47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 02:56:59 -0400
In-Reply-To: <1435730034-18284-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed,  1 Jul 2015 11:23:54 +0530

> Current code checks only rx work done to complete napi. It completely ignores
> tx work done. If we have only tx packets to clean and no rq work, we always
> napi complete instead of re-poll. Change this behavior to re-poll until
> tx work_done + rx work_done is not 0.

The existing TX behavior is correct, please do not change it.

You should never count TX work against the NAPI poll budget, it is
only for RX work.
