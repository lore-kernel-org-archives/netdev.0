From: Cong Wang <cwang@twopensource.com>
Subject: Re: RTNL: assertion failed at net/core/dev.c (4494) and RTNL:
 assertion failed at net/core/rtnetlink.c (940)
Date: Thu, 6 Feb 2014 14:12:25 -0800
Message-ID: <CAHA+R7McuqYDshugsWcaeBbBsEg3QY59LiovYthcq6bH1fLTNg@mail.gmail.com>
References: <20140206205106.GA10488@glanzmann.de>
	<CAHA+R7OGS_KG1un36KBixbgs7LTPWGRYdJ+Vsn2iM0FzNV5FzA@mail.gmail.com>
	<30988.1391723318@death.nxdomain>
	<31272.1391724462@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Thomas Glanzmann <thomas@glanzmann.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@redhat.com>, andy@greyhouse.net,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:59626 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708AbaBFWM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:12:27 -0500
Received: by mail-la0-f48.google.com with SMTP id mc6so1965024lab.21
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 14:12:25 -0800 (PST)
In-Reply-To: <31272.1391724462@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 6, 2014 at 2:07 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>>Cong Wang <cwang@twopensource.com> wrote:
>>
>>
>>       That would eliminate the warning, but is suboptimal.  Acquiring
>>RTNL is not necessary on the vast majority of state machine runs
>>(because no state changes take place, i.e., no ports are disabled or
>>enabled).  The above change would add 10 round trips per second to RTNL,
>>which seems excessive.
>>
>>       Also, we cannot unconditionally acquire RTNL in this function,
>>as it would race with the call to cancel_delayed_work_sync from
>>bond_close (via bond_work_cancel_all).

OK.

>
>         Thought of one more problem: we can't hold a regular lock while
> calling rtmsg_ifinfo, as it may sleep in alloc_skb.  The rtmsg_ifinfo
> call has to be RTNL and nothing else.
>

s/GFP_KERNEL/GFP_ATOMIC/
