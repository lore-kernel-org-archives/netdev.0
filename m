From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Mon, 25 Jul 2011 08:44:13 -0700
Message-ID: <4E2D8F4D.2000009@schaufler-ca.com>
References: <201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>	<20110722.082224.688620059032914637.davem@davemloft.net>	<4E2A7273.7030504@msgid.tls.msk.ru>	<201107231939.FIF21882.QHOSOFtMFVLFOJ@I-love.SAKURA.ne.jp>	<20110725222010.0b284042@kryten> <201107252215.GBG95887.OQVMFOOJLSFFHt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, mjt@tls.msk.ru, davem@davemloft.net,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm23.bullet.mail.sp2.yahoo.com ([98.139.91.93]:46958 "HELO
	nm23.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751668Ab1GYPoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 11:44:23 -0400
In-Reply-To: <201107252215.GBG95887.OQVMFOOJLSFFHt@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/25/2011 6:15 AM, Tetsuo Handa wrote:
> Anton Blanchard wrote:
>>>> When I saw recvmmsg()/sendmmsg() here, my first thought was an
>>>> authoritative DNS server which can read several requests at a
>>>> time and answer them all at once too - this way it all will go
>>>> to different addresses.
>>> I don't know what application wants sendmmsg(). Since users can send
>>> up to UIO_MAXIOV (= 1024) "struct iovec" blocks using sendmsg(), they
>>> will use sendmsg() rather than sendmmsg() if the destination address
>>> are the same.
>> But if an application needs to maintain packet boundaries, then sendmsg
>> isn't going to help is it?
> Well, such application might want to use RDM or SeqPacket... but your point is
> to maintain packet boundaries. You are assuming that sendmmsg() will be used
> for sending as much data as possible while preserving packet boundaries.
>
> OK. Then, the question is how to reduce performance loss by redundant
> security_socket_sendmsg() calls.

Not to be splitting hairs, but if the packets are headed to
different destinations the calls to security_socket_sendmsg()
are not redundant, they are necessary and appropriate. What
you have with sendmmsg() is an optimization that sacrifices
correctness for performance.

> If sendmmsg() likely contains single (or few)
> destination(s), trying to optimize security_socket_sendmsg() calls by comparing
> destination address (as proposed at
> http://www.spinics.net/linux/fedora/linux-security-module/msg11510.html
> ) would help. Otherwise, no optimization (as proposed at
> http://www.spinics.net/linux/fedora/linux-security-module/msg11504.html
> ) would be better. Which approach do you like?

I fear that you are going to find that the work you have
to do to reduce the number of calls is going to outweigh
the benefits of your optimization, as has been pointed out
earlier. My recommendation is that the sendmmsg() interface
is ill conceived and that you should look for alternative
ways to improve the performance of the use case.

