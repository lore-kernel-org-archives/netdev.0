From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 1/2] libnetlink: add a variant of
 rtnl_send_check that consumes ACKs
Date: Wed, 23 Dec 2015 13:17:55 -0800
Message-ID: <20151223131755.42a09baf@xeon-e3>
References: <20151221214222.5ee87383@xeon-e3>
	<1450773094-7978-1-git-send-email-lorenzo@google.com>
	<1450773094-7978-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35292 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbbLWVRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 16:17:48 -0500
Received: by mail-pa0-f47.google.com with SMTP id jx14so111163218pad.2
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 13:17:48 -0800 (PST)
In-Reply-To: <1450773094-7978-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Dec 2015 17:31:33 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

> The new variant is identical to rtnl_send_check, except it also
> consumes the kernel response instead of using MSG_PEEK. This is
> useful for callers that send simple commands that never cause a
> response but only ACKs, and that expect to receive and deal
> with errors without printing them to stderr like rtnl_talk does.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Originally, iproute2 used netlink so that every request had an ACK and
this is the API in rtnl_talk. Then as an optimization it was observed
that ACK from kernel is not necessary (all error reports are handled in
send), but that for some asynchronous errors a check was necessary.

Therefore, I wonder why you need this, either:
 * don't ask kernel for ACK's (like most other ip commands),
 * or use rtnl_talk() and expect ACK.
