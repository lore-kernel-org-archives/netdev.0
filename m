From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Wed, 21 Jul 2010 11:45:09 -0700 (PDT)
Message-ID: <20100721.114509.37203355.davem@davemloft.net>
References: <201007170114.GFC57373.SQJHOVtLFMOFFO@I-love.SAKURA.ne.jp>
	<20100716.123558.71592004.davem@davemloft.net>
	<201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 17 Jul 2010 10:17:10 +0900

> NETWORKING [IPv4/IPv6] maintainers and Paul, is below patch fine for you?

Unfortunately, after further consideration, I must reject this patch
and also the post accept() LSM hook one.

Sorry.

I looked into history of the discussions on this issue, and I have found
that the core issue with these hooks has not been addressed.

We must ensure that if:

1) Application makes poll() on UDP socket in blocking mode, and UDP
   reports that receive data is available

and

2) Application, after such a poll() call, makes a blocking recvmsg() call
   and no other activity has occurred on the socket meanwhile

Then we MUST return immediately with that available data.

This LSM hook, when it triggers, can violate this rule, even if you do
this looping thing.

The post accept() hook has the same problems.

Here is where we originally discussed this, in detail:

http://www.spinics.net/lists/netdev/msg95660.html

Therefore, I think this shows that what Tomoyo is trying to do is
fatally flawed.  We brought this fundamental issue up to you about a
year ago, and the issue is still not addressed.

So consider very seriously, that what you are trying to do cannot be
performed without breaking applications and API behavioral
expectations.
