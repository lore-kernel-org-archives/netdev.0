From: jamal <hadi@cyberus.ca>
Subject: Re: More tc action mess
Date: 19 Jan 2005 08:10:57 -0500
Message-ID: <1106140256.1049.903.camel@jzny.localdomain>
References: <41EDEB97.3080503@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41EDEB97.3080503@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-19 at 00:09, Patrick McHardy wrote:
> I probably found the reason for the problems with the ipt action you were
> talking about. netfilter targets, like tc actions, expect a struct 
> sk_buff **,
> but the ipt action does:
> 
>         struct sk_buff *skb = *pskb;
> ...
>         ret = p->t->u.kernel.target->target(&skb, skb->dev, NULL,
> 
> which of course doesn't make much sense. Unfortunately, tcf_action_exec
> does the same nonsense:
> 
> int tcf_action_exec(struct sk_buff *skb, struct tc_action *act,
> ...
>                         ret = a->ops->act(&skb, a);
> 
> This means we must convert all paths on which tcf_action_exec is called
> to use struct sk_buff ** :(
 

No, just restore the code that you took out in one of your patches
right above that line which reads:

----
        if (skb_cloned(skb)) {
                if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
                        return -1;
                }
        }
----

Depending on what you do in netfilter lately, you may wanna take out
the skb_cloned() call.


cheers,
jamal
