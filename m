From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] netlink: downgrade warning about leftover bytes to debug
 level
Date: Wed, 28 May 2014 11:18:09 +0200
Message-ID: <5385A9D1.4000102@redhat.com>
References: <1401196563-6999-1-git-send-email-mschmidt@redhat.com> <53859359.70304@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489AbaE1JSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 05:18:15 -0400
In-Reply-To: <53859359.70304@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2014 09:42 AM, Nicolas Dichtel wrote:
> Le 27/05/2014 15:16, Michal Schmidt a =C3=A9crit :
>> Any process is able to send netlink messages with leftover bytes, so
>> downgrade the warning message to pr_debug in order to avoid possible
>> kernel log spam.
> Yes, but that's not a normal case. I think that the level warning is =
good,
> there is something wrong with this kind of messages.

As an alternative we could at least guard it with net_ratelimit().

But still, the message indicates a userspace bug. It can be useful
for a developer of a netlink library, but not for many more.
I think it's odd to let unprivileged userspace spam the dmesg,
even if rate-limited. The kernel does not emit warning messages when
userspace is buggy in other ways, like calling syscalls with invalid
arguments.

Regards,
Michal
