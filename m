From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Tue, 14 Apr 2015 14:37:47 -0400 (EDT)
Message-ID: <20150414.143747.1155055158701231768.davem@davemloft.net>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, jengelh@medozas.de, jpirko@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbbDNShu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:37:50 -0400
In-Reply-To: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Tue, 14 Apr 2015 14:25:11 +0200

> On x86 allyesconfig build:
> The function compiles to 130 bytes of machine code.
> It has 493 callsites.
> Total reduction of vmlinux size: 27906 bytes.
> 
>    text	     data      bss       dec     hex filename
> 82447071 22255384 20627456 125329911 77861f7 vmlinux4
> 82419165 22255384 20627456 125302005 777f4f5 vmlinux5
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

That BUG_ON() was added 7 years ago, and I don't remember it ever
triggering or helping us diagnose something, so just remove it and
keep the function inlined.
