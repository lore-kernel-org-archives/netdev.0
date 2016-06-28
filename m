From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: fix out-of-order cn_proc netlink message delivery
Date: Tue, 28 Jun 2016 15:56:05 +0300
Message-ID: <1710991467118565@web17j.yandex.ru>
References: <1466773532-16596-1-git-send-email-aaron@monkey.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon DeVree <nuxi@vault24.org>
To: Aaron Campbell <aaron@monkey.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward2j.cmail.yandex.net ([5.255.227.20]:59969 "EHLO
	forward2j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752180AbcF1NDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:03:38 -0400
In-Reply-To: <1466773532-16596-1-git-send-email-aaron@monkey.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Aaron

24.06.2016, 16:07, "Aaron Campbell" <aaron@monkey.org>:
> The proc connector messages include a sequence number, allowing userspace
> programs to detect lost messages. However, performing this detection is
> currently more difficult than necessary, since netlink messages can be
> delivered to the application out-of-order. To fix this, leave pre-emption
> disabled during cn_netlink_send(), and use GFP_NOWAIT.
>
> The following was written as a test case. Building the kernel w/ make -j32
> proved a reliable way to generate out-of-order cn_proc messages.

This is not actually about out-of-order sending which is impossible iirc,
but the way fork pushes messages into socket queue in parallel. What you've done
is syncing one more layer higher.

I'm not against this patch if you think it does fix some issues, but wording is not correct imo.
