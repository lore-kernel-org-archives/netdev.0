From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Fri, 31 Dec 2004 15:18:49 +0100
Message-ID: <41D55FC9.6040605@trash.net>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123023.GO32419@postel.suug.ch> <1104467816.1049.181.camel@jzny.localdomain> <20041231131039.GI32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041231131039.GI32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * jamal <1104467816.1049.181.camel@jzny.localdomain> 2004-12-30 23:36
> 
> 
>>Patrick pointed this in other email: the xchg is sort of defeated by the
>>else. Perhaps make  the second one xchg as well.
> 
> Agreed, I changed it to:
> 
> 		struct tc_action *act;
> 		act = xchg(&dst->action, src->action);
> 		if (act)
> 			tcf_action_destroy(act, TCA_ACT_UNBIND);
> 
> Am I missing something?

Yes, the xchg without locking is only right in case we don't have
an existing action that needs to be destroyed. Someone might still
be looking at the old action in a softirq. If you want to keep the
"lockless" variant, you need to call synchronize_net() before
tcf_action_destroy().

Regards
Patrick
