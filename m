From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH PKT_SCHED 0/17]: tc action cleanup + fixes
Date: Thu, 30 Dec 2004 15:16:42 +0100
Message-ID: <41D40DCA.7090706@trash.net>
References: <41D3785F.3040909@trash.net>	 <1104382562.1048.39.camel@jzny.localdomain>  <41D3F5EC.9050808@trash.net> <1104413400.1047.123.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104413400.1047.123.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>>>b)Other things which i have seen compilers whine about in the past of
>>>the form:
>>>
>>>a missing cast
>>>-       a->priv = (void *) p;
>>>+       a->priv = p;
>>
>>No need to cast a pointer to void *, except if a->priv
>>was of some different type.
>> 
> So as long as lvalue was void you dont cast? p is certainly not void.

Exactly.

>>>4) Some of those messages are actually still useful and dont really
>>>harm to leave around for a little while longer;
>>>-       if (tb[TCA_PEDIT_PARMS - 1] == NULL) {
>>>-               printk("BUG: tcf_pedit_init called with NULL params\n");
>>>
>>>I realize the fixes you have to return -ENOMEN/NOENT etc are an
>>>improvement but a little ascii puking wont harm for somebody writting
>>>a user space app until we get better netlink error propagation
>>>in place.
>>
>>Agreed for some messages, but those should be DEBUGs. Anyway,
>>I didn't want to judge for every message and possible convert
>>it, so I deleted all printks that got replaced by error codes.
>>
> 
> the printks are meant to help a little more (and are mostly on the slow
> path); when the error propagation for netlink works well, those sorts of
> ascii messages will probably be transported back to user space. On any
> newer patches I suggest to just keep them.

Ok.

> Heres something else:
> Re: [PATCH PKT_SCHED 15/17]: Remove checks for impossible conditions in
> pedit action, you say:
> 
> 
>>Remove checks for impossible conditions in pedit action.
> 
> 
> ________________________________________________________________________
> [..]
> -	if (p == NULL) {
> 
>>-		printk("BUG: tcf_pedit_dump called with NULL params\n");
>>-		goto rtattr_failure;
>>-	}
>>-
> 
> 
> You have these type changes all over. These are certainly artifacts of the 
> development time, I may have have caught a bug or two via these checks at 
> the time. It is highly likely those bugs are fixed in the code merged.

Yes, I checked all paths before removing them.

> If they happen, however, they are a BUG and the possibility of a bug is
> still there ;-> i.e the word "impossible" is too strong a description. 
> Having said that:
> Is it better to have an oops catch this or have something print on the
> console or syslog indicating a bug? This is more a philosphical question
> and an answer could be "good practise is to let oops catch it". I am
> actually indifferent if those checks go - however if i had caught them
> myself i would have put unlikely() around them.

I prefer an Oops because it gives a backtrace, without requiring
additional checks in the code. The other reason I deleted them was
that not all of them printed something on the console, so some
bugs were just quietly ignored. And I didn't want to add more printks :)

> I will wait for you to finish before i start working on the eactions.
> 
> So a general comment to all the patches. All look good - I would prefer
> a check against size instead of EOPNOTSUPP for the two i pointed at.
> And going forward, prefer you leave the printks i had for errors but fix
> the return codes to be more meaningful. So only those two i pointed at
> with EOPNOTSUPP i am not ACKing (my basic tests will break) - rest Dave
> can push in.

Thanks. Dave is on holidays until next week, I'll fix them
up until then.

Regards
Patrick
