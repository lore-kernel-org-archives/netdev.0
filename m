From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Fri, 31 Dec 2004 15:35:22 +0100
Message-ID: <20041231143522.GM32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123023.GO32419@postel.suug.ch> <1104467816.1049.181.camel@jzny.localdomain> <20041231131039.GI32419@postel.suug.ch> <41D55FC9.6040605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41D55FC9.6040605@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41D55FC9.6040605@trash.net> 2004-12-31 15:18
> Thomas Graf wrote:
> >		struct tc_action *act;
> >		act = xchg(&dst->action, src->action);
> >		if (act)
> >			tcf_action_destroy(act, TCA_ACT_UNBIND);
> >
> >Am I missing something?
> 
> Yes, the xchg without locking is only right in case we don't have
> an existing action that needs to be destroyed. Someone might still
> be looking at the old action in a softirq. If you want to keep the
> "lockless" variant, you need to call synchronize_net() before
> tcf_action_destroy().

You're absolutely right. I will put locks around it again to avoid
having the pointer exchanged in the middle of a classification.
A synchronize_net will avoid the crash but will no prevent a
possible corruption of the classification result if the action is used
more than once.
