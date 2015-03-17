From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH net-next v4 3/3] Validate all netlink attributes and
 return error if any of the validation fails.
Date: Tue, 17 Mar 2015 10:29:28 +0530
Message-ID: <CA+CtxLRR1LiotUPk=Pi995+6PF8ys72Zx1xbAevX7CTF9H4u9g@mail.gmail.com>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
	<5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
	<20150317.002427.1841301696338614194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Scott Feldman <sfeldma@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:33896 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbCQE73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:59:29 -0400
Received: by wegp1 with SMTP id p1so52327618weg.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:59:28 -0700 (PDT)
In-Reply-To: <20150317.002427.1841301696338614194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 9:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Siva Mannem <siva.mannem.lnx@gmail.com>
> Date: Tue, 17 Mar 2015 04:32:44 +0530
>
>> This patch validates all netlink attributes and return error if any of the
>> validation fails.
>>
>> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
>> Suggested-by: David Miller <davem@davemloft.net>
>
> You have to remove the range checking code from all the other
> functions too.
>
> Then no errors can be returned by them at all actually and that's an
> really nice cleanup.
>
> Please don't make microscopic narrow changes like this, think about
> the higher level implications and the things that are no longer
> necessary as a result.
>
> Thanks.

These functions(br_set_forward_delay/hello_time/max_age/ageing_time)
are also called from other places i.e old_dev_ioctl() and sysfs code. If
range checking has to be removed from these functions, then the same
has to be added in the path from where they are being invoked.

As Scott mentioned,  these functions can be enhanced to take
extra argument to avoid extra range checking happening in br_changelink()
path. Is this approach ok?
-- 
Regards,
Siva Mannem.
