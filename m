From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Mon, 25 Jul 2011 10:00:29 -0700
Message-ID: <4E2DA12D.70003@schaufler-ca.com>
References: <4E2A7273.7030504@msgid.tls.msk.ru>	<201107231939.FIF21882.QHOSOFtMFVLFOJ@I-love.SAKURA.ne.jp>	<20110725222010.0b284042@kryten>	<201107252215.GBG95887.OQVMFOOJLSFFHt@I-love.SAKURA.ne.jp>	<4E2D8F4D.2000009@schaufler-ca.com> <201107260143.CGH18263.FOOSVMOQFJFLHt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, mjt@tls.msk.ru, davem@davemloft.net,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107260143.CGH18263.FOOSVMOQFJFLHt@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/25/2011 9:43 AM, Tetsuo Handa wrote:
> Casey Schaufler wrote:
>>> OK. Then, the question is how to reduce performance loss by redundant
>>> security_socket_sendmsg() calls.
>> Not to be splitting hairs, but if the packets are headed to
>> different destinations the calls to security_socket_sendmsg()
>> are not redundant, they are necessary and appropriate. What
>> you have with sendmmsg() is an optimization that sacrifices
>> correctness for performance.
> Excuse me, but this thread is not trying to remove necessary and appropriate
> security_socket_sendmsg() calls. Linux 3.0 was released without necessary and
> appropriate security_socket_sendmsg() calls, and I'm trying to correct it (via
> msg11504.html or msg11510.html) for Linux 3.0.x stable release.

I understand. Sorry if I did a poor job of jumping into
the thread.

>> I fear that you are going to find that the work you have
>> to do to reduce the number of calls is going to outweigh
>> the benefits of your optimization, as has been pointed out
>> earlier.
> I fear it too. Unless many dozens (maybe some hundreds) of packets are sent by
> sendmmsg(), msg11504.html might show better performance than msg11510.html .
> But I don't have a machine to benchmark.

Is there some chance that the original authors could step up
to help with the benchmarking effort on this repair? Having been
on the end where I introduced problems more than once, I have a
good understanding of the principle "you broke it, you bought it".

