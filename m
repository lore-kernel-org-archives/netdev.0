From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6 1/5]: Fix locking in __qdisc_destroy rcu-callback
Date: Wed, 4 Aug 2004 09:33:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804093328.4ee56d30.davem@redhat.com>
References: <410FAD44.7020503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <410FAD44.7020503@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Aug 2004 17:20:36 +0200
Patrick McHardy <kaber@trash.net> wrote:

> The __qdisc_destroy rcu-callback doesn't do any locking when calling
> ops->reset and ops->destroy. qdisc_destroy is often called from both
> of these functions and it changes dev->qdisc_list. This patch adds proper
> locking to __qdisc_destroy. Unfortunately when using qdisc_tree_lock in
> process context we now also need to disable local bh's to avoid beeing
> interrupted by the rcu-callback. I'm not sure if RCU callback can be
> scheduled while the kernel is running in process context, so this may
> be unneccessary.

RCU callbacks run via tasklets, and thus in softirq context,
thus your locking changes to _bh() are indeed necessary.

I will apply this patch, thanks Patrick.
