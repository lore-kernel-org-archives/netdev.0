From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats in	action	policer
Date: Mon, 20 Dec 2004 11:17:48 +0100
Message-ID: <41C6A6CC.1050105@trash.net>
References: <20041215130128.GK8493@postel.suug.ch>	 <1103119774.1077.74.camel@jzny.localdomain>  <41C05B60.6030504@trash.net> <1103484249.1046.143.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1103484249.1046.143.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2004-12-15 at 10:42, Patrick McHardy wrote:
> 
>>Since
>>this problem is not related to the policer oops fix it doesn't
>>convince me that my time would have been well invested doing the
>>tests you described.
> 
> 
> But it is _absolutely_ related to the policer oops.
> If those tests were run to begin with there would be no oops neither
> this latest problem. 

I agree that this problem would have been avoided if the
regression tests were run when the change was made, and it
made sense to run them at that time. Unfortunately I missed
the patch when it went in, otherwise I would have objected
to using a field called "priv" and making assumptions about
the layout of the structure it points to in a file called
act_api anyway.

But reshuffling structure members of a structure not exposed
to userspace doesn't require testing tc, and doesn't require
testing old kernels. This was the only point I was trying to
make, I run tests when they make sense, but not because I might
find something unrelated by accident. As an exception to this,
I am willing to run unrelated tests if it is little overhead
(== fully automatic).

Even following your logic (We cant compromise quality by
handwaving on instinct. Famous last words: "that couldnt have
possibly caused a bug down there") I need to either test the
entire kernel after each change ("down there" could be
anywhere), or judge for myself which parts to test. Blindly
running regression tests isn't going to do much good.

> Hopefully with the regression tests in place this will get better.

On a side-note, you both seem to be inventing your own testing
framework and regression tests. tcng already includes lots of
regression tests for tc, tcng and the kernel. Unfortunately,
last time I checked, it didn't work with 2.6.

> [You fear Murphy less than i - and thats a style difference. Your style
> is actually more effective in Linux because you can distribute the
> burden onto users. As a matter of fact it is within Daves tolerance
> range (but not mine[1]). So you should do just fine]

I don't feel like I'm distributing burden onto anyone. As I
said, I run the tests I deem necessary, and I never send out
patches of whichs correctness I'm not convinced. So far, my
history of mistakes has been pretty good.

Regards
Patrick
