From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ip_sockglue.c: copy msg_control optval from user
 to kernel space
Date: Sat, 16 Jan 2010 00:50:23 -0800 (PST)
Message-ID: <20100116.005023.137878764.davem@davemloft.net>
References: <201001151024.59482.hartleys@visionengravers.com>
	<20100115.173044.102257749.davem@davemloft.net>
	<BD79186B4FD85F4B8E60E381CAEE19091E790C@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752103Ab0APIuS@vger.kernel.org>
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19091E790C@mi8nycmail19.Mi8.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Date: Sat, 16 Jan 2010 01:22:21 -0500

> On Fri 1/15/2010 8:30 PM, David Miller wrote:
>> How did you test your change?
> 
> Hmm... I saw the sparse warning and tried this to fix it. The code compiled
> fine and the warning was gone. When I booted the resulting kernel I didn't
> see any issues. I must not have went down this code path in my testing.

I'm going to ask you a second time.

What was your test case?  How did you test the change?

I don't think you tested your change at all besides seeing that gcc
would accept the code and sparse stopped spitting out a warning.  And
you're vagueness about your testing methodology will only work to
confirm my suspicions.

I find it unlikely, at best, for you to have tested that code path, as
'msg' is an uninitilized stack variable at this point in the code, so
'msg->msg_control' is going to be a garbage pointer, and therefore
copying to it would result in a crash.

I don't even think you read and understood the code you are editing.

I suspect you just wanted to kill the sparse warning somehow, you
found a way that made the compiler and sparse eat it, and you simply
ran with it.

And that really upsets me.

Fixing sparse warnings should not be a mindless exercise.  You should
understand the code you are changing.
