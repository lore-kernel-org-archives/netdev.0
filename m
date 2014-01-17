From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] tipc: align TIPC behaviours of waiting
 for events with other stacks
Date: Thu, 16 Jan 2014 19:11:40 -0800 (PST)
Message-ID: <20140116.191140.184722722665650663.davem@davemloft.net>
References: <1389923407-26969-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Paul.Gortmaker@windriver.com, maloy@donjonn.com,
	jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbaAQDLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 22:11:41 -0500
In-Reply-To: <1389923407-26969-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 17 Jan 2014 09:50:02 +0800

> Comparing the current implementations of waiting for events in TIPC
> socket layer with other stacks, TIPC's behaviour is very different
> because wait_event_interruptible_timeout()/wait_event_interruptible()
> are always used by TIPC to wait for events while relevant socket or
> port variables are fed to them as their arguments. As socket lock has
> to be released temporarily before the two routines of waiting for
> events are called, their arguments associated with socket or port
> structures are out of socket lock protection. This might cause
> serious issues where the process of calling socket syscall such as
> sendsmg(), connect(), accept(), and recvmsg(), cannot be waken up
> at all even if proper event arrives or improperly be woken up
> although the condition of waking up the process is not satisfied
> in practice.
> 
> Therefore, aligning its behaviours with similar functions implemented
> in other stacks, for instance, sk_stream_wait_connect() and
> inet_csk_wait_for_connect() etc, can avoid above risks for us.

Series applied, thank you.
