From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH PKT_SCHED 0/17]: tc action cleanup + fixes
Date: 29 Dec 2004 23:56:02 -0500
Message-ID: <1104382562.1048.39.camel@jzny.localdomain>
References: <41D3785F.3040909@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D3785F.3040909@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick,
Thanks for this cleanup.

Questions/comments:

1)compiler or style issue?

You have a few of fixes from

a)
 if (..){
	single statement here;
}
 
to:
if (..)
	single statement here;

I always add an extra pair of brace
for lazy reasons (in the back of my mind: incase i want to add another
statement ;->).

b)Other things which i have seen compilers whine about in the past of
the form:

a missing cast
-       a->priv = (void *) p;
+       a->priv = p;

or unitialized vars:
-       struct tcf_pedit *p = NULL;
+       struct tcf_pedit *p;
 

2) You are not the first to not like the 
if (constant != variable_here) 

Should be noted that i am dyxlesic and this has saved 
me a few times (I would say the most common errata for me, weird as that
may sound). Dont have a problem with the changes you made
(dont need the protection at this stage;->).

3) Is there any reason in which some cases you fixed things to be:

return_type
functionname() eg
-static int
-gact_net_rand(struct tcf_gact *p) {
+static int gact_net_rand(struct tcf_gact *p)

and in some cases you leave them to be of the form:
return_type functionname()

4) Some of those messages are actually still useful and dont really
harm to leave around for a little while longer;
-       if (tb[TCA_PEDIT_PARMS - 1] == NULL) {
-               printk("BUG: tcf_pedit_init called with NULL params\n");

I realize the fixes you have to return -ENOMEN/NOENT etc are an
improvement but a little ascii puking wont harm for somebody writting
a user space app until we get better netlink error propagation
in place.

I will look closely at one or two of those fixes in the morning;
majority look good on first quick scan (most things were needed during
development or are artifacts of that period and are safe to rid of now).

Again thanks for the good work.

cheers,
jamal

On Wed, 2004-12-29 at 22:39, Patrick McHardy wrote:
> Hi Jamal,
> 
> here is what I got so far, I'll continue tommorrow. Only compile
> tested yet. Please review and comment.
> 
> Patrick McHardy:
>    o [PKT_SCHED]: Disable broken override bits in pedit action
>    o [PKT_SCHED]: Return proper error codes in tcf_pedit_init
>    o [PKT_SCHED]: Remove checks for impossible conditions in pedit action
>    o [PKT_SCHED]: Clean up pedit action
>    o [PKT_SCHED]: Clean up tcf_ipt_init
>    o [PKT_SCHED]: Fix missing unlock in ipt action error path
>    o [PKT_SCHED]: Remove checks for impossible conditions in ipt action
>    o [PKT_SCHED]: Clean up ipt action
>    o [PKT_SCHED]: Return -EOPNOTSUPP if gact probability is requested 
> but not compiled in
>    o [PKT_SCHED]: Return proper error codes in tcf_gact_init
>    o [PKT_SCHED]: Remove checks for impossible conditions in gact action
>    o [PKT_SCHED: Clean up gact action
>    o [PKT_SCHED]: Clean up act_api.c action init path, propagate errors 
> properly
>    o [PKT_SCHED]: Check TCA_ACT_KIND payload size _before_ copying it
>    o [PKT_SCHED]: Remove checks for impossible conditions in act_api.c
>    o [PKT_SCHED]: Consistent comparision style in act_api.c
>    o [PKT_SCHED]: act_api.c whitespace cleanup
>  
> 
> Regards
> Patrick
> 
> 
