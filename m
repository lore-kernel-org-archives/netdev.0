From: Mike Danese <mikedanese@google.com>
Subject: Re: [PATCH] net: refactor icmp_global_allow to improve readability
 and performance.
Date: Fri, 1 Jan 2016 19:20:41 -0800
Message-ID: <CAMu1AU5vWoV9+vSq-zbfkcT4+8kxZvr-RQZqUY7GmcSe4KyFYg@mail.gmail.com>
References: <1451635091-109673-1-git-send-email-mikedanese@google.com>
	<1451689635.8255.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	open list <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451689635.8255.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, I completely missed the purpose of that. As a new year's
resolution, I resolve to read the comments.

Thanks for the review!

On Fri, Jan 1, 2016 at 3:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-12-31 at 23:58 -0800, Mike Danese wrote:
>> We can reduce the number of operations performed by icmp_global_allow
>> and make the routine more readable by refactoring it in two ways:
>>
>> First, this patch refactors the meaning of the "delta" variable. Before
>> this change, it meant min("time since last refill of token bucket", HZ).
>> After this change, it means "time since last refill". The original
>> definition is required only once but was being calculated twice. The new
>> meaning is also more intuitive for a variable named "delta".
>>
>> Second, by calculating "delta" (time since last refill of token bucket)
>> and "cbr" (token bucket can be refilled) at the beginning of the
>> routine, we reduce the number of repeated calculations of these two
>> variables.
>>
>> There should be no functional difference.
>>
>> Signed-off-by: Mike Danese <mikedanese@google.com>
>> ---
>>  net/ipv4/icmp.c | 17 ++++++++---------
>>  1 file changed, 8 insertions(+), 9 deletions(-)
>
> Hi Mike
>
> Sorry, this is a very broken patch.
>
> There is a comment you apparently missed completely :
>
> /* Check if token bucket is empty and cannot be refilled
>  * without taking the spinlock.
>  */
>
> There is a reason we compute 'delta' two times.
>
> One without the spinlock held, and a second time with the spinlock held.
>
> This is an opportunistic way to exit early without false sharing in the
> stress case where many cpus might enter this code.
>
> Really I do not think current code needs any 'refactoring', especially
> around December 31th at midnight ;)
>
>
>
