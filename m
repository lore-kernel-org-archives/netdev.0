From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix ip link add netns oops
Date: Sun, 30 Jan 2011 01:15:25 -0800 (PST)
Message-ID: <20110130.011525.39175277.davem@davemloft.net>
References: <m1fwsbus25.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eswierk@bigswitch.com, stable@kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751776Ab1A3JOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 04:14:50 -0500
In-Reply-To: <m1fwsbus25.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 29 Jan 2011 16:57:22 -0800

> 
> Ed Swierk <eswierk@bigswitch.com> writes:
>> On 2.6.35.7
>>  ip link add link eth0 netns 9999 type macvlan
>> where 9999 is a nonexistent PID triggers an oops and causes all network functions to hang:
>> [10663.821898] BUG: unable to handle kernel NULL pointer dereference at 000000000000006d
>>  [10663.821917] IP: [<ffffffff8149c2fa>] __dev_alloc_name+0x9a/0x170
 ...
> This bug was introduced in:
> commit 81adee47dfb608df3ad0b91d230fb3cef75f0060
> Author: Eric W. Biederman <ebiederm@aristanetworks.com>
> Date:   Sun Nov 8 00:53:51 2009 -0800
> 
>     net: Support specifying the network namespace upon device creation.
...
> Where apparently I forgot to add error handling to the path where we create
> a new network device in a new network namespace, and pass in an invalid pid.
> 
> Cc: stable@kernel.org
> Reported-by: Ed Swierk <eswierk@bigswitch.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks Eric.
