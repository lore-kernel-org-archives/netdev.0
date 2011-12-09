From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH RESEND] sctp: fix incorrect overflow check on autoclose
Date: Fri, 9 Dec 2011 13:04:34 -0500
Message-ID: <8EEC521A-CA38-4CE9-BCFD-BA6FC9A85D18@gmail.com>
References: <1323393883-3759-1-git-send-email-xi.wang@gmail.com> <4EE2478B.5010409@hp.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41261 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab1LISEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 13:04:38 -0500
In-Reply-To: <4EE2478B.5010409@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 9, 2011, at 12:38 PM, Vladislav Yasevich wrote:
> I think this should be u32 since that's what sp->autoclose is.

Do you mean something like this?

	min_t(u32, sp->autoclose, MAX_SCHEDULE_TIMEOUT / HZ)

On 64-bit platform this would limit autoclose for no good
reason to

	(u32)(MAX_SCHEDULE_TIMEOUT / HZ),

which is basically 0x978d4fdf (assuming HZ is 250).  I guess the
intention was to allow autoclose to be any u32 on 64-bit platform.

- xi
