From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: rtnl_mutex deadlock?
Date: Wed, 5 Aug 2015 09:43:30 +0200
Message-ID: <20150805074330.GA2084@nanopsycho.orion>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
 <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Network Development <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:32932 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbbHEHnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 03:43:33 -0400
Received: by wijp15 with SMTP id p15so36442858wij.0
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 00:43:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 05, 2015 at 07:31:30AM CEST, cwang@twopensource.com wrote:
>On Tue, Aug 4, 2015 at 8:48 AM, Linus Torvalds
><torvalds@linux-foundation.org> wrote:
>> Sorry for the spamming of random rtnetlink people, but I just resumed
>> my laptop at PDX, and networking was dead.
>>
>> It looks like a deadlock on rtnl_mutex, possibly due to some error
>> path not releasing the lock. No network op was making any progress,
>> and as you can see from the attached sysrq-w, it all seems to be hung
>> in rtnl_lock().
>>
>> The call trace from NetworkManager looks different from the others,
>> and looks to me like it might actually be a recursive invocation of
>> rtnetlink_rcv(), but since I have a fairly light configuration on this
>> laptop and don't have frame pointers enabled, I'm not sure how
>> reliable that stack trace is. It might be just stale entries. But if
>> they aren't stale, then that would certainly explain the deadlock.
>>
>
>You are right, looks like kernel received a GETLINK netlink message
>from NetworkManager and then replied back but accidentally sent the
>reply to itself, seems something wrong with NETLINK_CB(skb).portid.

Indeed. Most probably, NETLINK_CB(skb).portid got zeroed.

Linus, are you able to reproduce this or is it a one-time issue?

Thanks!
