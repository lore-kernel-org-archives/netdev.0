From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2 0/5] ila: Optimization to preserve value of
 early demux
Date: Thu, 3 Dec 2015 11:59:31 -0800
Message-ID: <CALx6S358G5c47hUEHMYmhkZjnTqfAOD9kEEk2L92Y15TYA7=eg@mail.gmail.com>
References: <1449011472-1459652-1-git-send-email-tom@herbertland.com>
	<20151203.144845.271629627276792795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33604 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264AbbLCT7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:59:31 -0500
Received: by iouu10 with SMTP id u10so95078024iou.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 11:59:31 -0800 (PST)
In-Reply-To: <20151203.144845.271629627276792795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 11:48 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 1 Dec 2015 15:11:07 -0800
>
>> ip6tables -t mangle -A PREROUTING --dst 2001:0:0:33::/64 -j ILAIN
>
> The user should have to do anything like this in order to just get
> proper working functionality of ILA.
>
> It should just work transparently.

This was transparent in the previously posted patch "ila: Add support
for netfilter NF_INET_PRE_ROUTING hook", but there was significant
pushback that NF interface was not intended for this purpose. Using an
IP tables target like this should preserve the sanctity of the
interfaces and does provide nice performance improvement since
PREROUTING is done before early demux. The NF_INET_PRE_ROUTING hook is
still better performance though and what we are using internally (just
an incremental change on top of these patches).
