From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH PKT_SCHED 0/17]: tc action cleanup + fixes
Date: Thu, 30 Dec 2004 13:34:52 +0100
Message-ID: <41D3F5EC.9050808@trash.net>
References: <41D3785F.3040909@trash.net> <1104382562.1048.39.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104382562.1048.39.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Patrick,
> Thanks for this cleanup.
> 
> Questions/comments:
> 
> 1)compiler or style issue?
> 
> You have a few of fixes from
> 
> a)
>  if (..){
> 	single statement here;
> }
>  
> to:
> if (..)
> 	single statement here;
> 
> I always add an extra pair of brace
> for lazy reasons (in the back of my mind: incase i want to add another
> statement ;->).

Just cleanup, I prefer not to waste too many lines. Saving
space increases readability.

> 
> b)Other things which i have seen compilers whine about in the past of
> the form:
> 
> a missing cast
> -       a->priv = (void *) p;
> +       a->priv = p;

No need to cast a pointer to void *, except if a->priv
was of some different type.

> 
> or unitialized vars:
> -       struct tcf_pedit *p = NULL;
> +       struct tcf_pedit *p;

p is assigned another value before the first use, so
initializing to NULL is not neccessary.

> 2) You are not the first to not like the 
> if (constant != variable_here) 
> 
> Should be noted that i am dyxlesic and this has saved 
> me a few times (I would say the most common errata for me, weird as that
> may sound). Dont have a problem with the changes you made
> (dont need the protection at this stage;->).

The compiler warns about assignments in comparisions nowadays.

> 3) Is there any reason in which some cases you fixed things to be:
> 
> return_type
> functionname() eg
> -static int
> -gact_net_rand(struct tcf_gact *p) {
> +static int gact_net_rand(struct tcf_gact *p)
> 
> and in some cases you leave them to be of the form:
> return_type functionname()

Just saving empty lines. I didn't try to be consistent with
this, In case I changed it the other way around it's usually
to keep all arguments on one line without exceeding 80 chars.

> 
> 4) Some of those messages are actually still useful and dont really
> harm to leave around for a little while longer;
> -       if (tb[TCA_PEDIT_PARMS - 1] == NULL) {
> -               printk("BUG: tcf_pedit_init called with NULL params\n");
> 
> I realize the fixes you have to return -ENOMEN/NOENT etc are an
> improvement but a little ascii puking wont harm for somebody writting
> a user space app until we get better netlink error propagation
> in place.

Agreed for some messages, but those should be DEBUGs. Anyway,
I didn't want to judge for every message and possible convert
it, so I deleted all printks that got replaced by error codes.

> I will look closely at one or two of those fixes in the morning;
> majority look good on first quick scan (most things were needed during
> development or are artifacts of that period and are safe to rid of now).

Thanks, I'll continue later today and send another batch
tonight.

Regards
Patrick
