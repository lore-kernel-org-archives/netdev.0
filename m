From: Juliusz Chroboczek <jch@pps.jussieu.fr>
Subject: Re: [PATCH 1/2] Stochastic Fair Blue queue discipline, take two
Date: Sat, 24 May 2008 03:44:55 +0200
Message-ID: <87tzgojx0o.fsf@pirx.pps.jussieu.fr>
References: <87iqyqajtp.fsf@pirx.pps.jussieu.fr> <4801B574.3050406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from witko.kerneis.info ([213.186.56.95]:36160 "EHLO
	witko.kerneis.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187AbYEXCKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 22:10:51 -0400
In-Reply-To: <4801B574.3050406@trash.net> (Patrick McHardy's message of "Sun\, 13 Apr 2008 09\:25\:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 April 2008, I wrote

>> The following is a second take on the sfb qdisc...

On 13 April, Patrick McHardy was kind enough to review my patch in
Message-ID <4801B574.3050406@trash.net>, which you'll find on

  http://mid.gmane.org/4801B574.3050406@trash.net

Sorry for the delay, but I really didn't have any time to work on fun
stuff since then.

There are quite a few things in Patrick's message that I don't understand.

>> +struct tc_sfb_qopt {
...
> I'd suggest to use nested attributes, even if you currently don't
> have plans to add new members. The uglyness necessary to do this
> later on is not really worth the small saving in netlink bandwidth.

Could you please clarify what you mean?  Perhaps by pointing me to
some code?

>> +	int i;

> Please use unsigned types where possible.

Is that a hard requirement?  (I happen to prefer int, which I find
more readable.)

>> +	u16 minqlen = (u16)(~0);

> Unnecessary cast and unnecessary parens.

I realise that, but I dislike having non-trivial operations
(truncation) being done by the assignment operation.  Is that a hard
requirement?

>> +	child = sfb_create_dflt(sch, limit);
>> +	if (child == NULL)
>> +		return -ENOMEM;
>> +
>> +	sch_tree_lock(sch);
>> +	if (child) {

> child == NULL is impossible ehere since its checked above. Replacing
> the inner qdisc shouldn't be done unconditionally though, the default
> should only be a default for the initial qdisc.

Please clarify.  This is code that was copied verbatim from sch_red,
and I do not understand it.

Perhaps it'd be better if you made the needed changes to sch_red first?

>> +	q->qdisc = &noop_qdisc;

> The noop_qdisc assignment looks unnecessary, its replaced unconditionally.

Again, this is code copied verbatim from sch_red.  Please make the
changes there first, I'm a little nervous about modifying code I don't
understand.

>> +	struct tc_sfb_qopt opt = { .rehash_interval = q->rehash_interval,
>> +				   .db_interval = q->db_interval,
>> +				   .hash_type = q->hash_type,
>> +				   .limit = q->limit,
>> +				   .max = q->max,
>> +				   .target = q->target,
>> +				   .increment = q->increment,
>> +				   .decrement = q->decrement,
>> +				   .penalty_rate = q->penalty_rate,
>> +				   .penalty_burst = q->penalty_burst,
>> +	};

> Please reindent this correctly by using two tabs (same for other
> C99 initializers).

Please clarify, and point me to a suitable example.  I'm just
following the style in sch_red.

Thanks for your help,

                                        Juliusz
