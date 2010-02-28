From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Why does connector use a work queue???
Date: Sun, 28 Feb 2010 22:52:43 +0300
Message-ID: <20100228195243.GA15976@ioremap.net>
References: <m1pr3qcbk1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1pr3qcbk1.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 27, 2010 at 06:57:02PM -0800, Eric W. Biederman (ebiederm@xmission.com) wrote:
> These days netlink callbacks for messages happen in the context of the
> process who sent the message.  Things like permission checks are much
> more complicated if we don't use that process context.
> 
> I was looking at removing NETLINK_CB(skb).eff_cap but I discovered
> that connected takes the netlink messages, them from their
> perfectly good process context, and puts the into a workqueue
> for reasons that are not apparent to me.

Netlink was made synchronous rather recently and connector was not
changed to take advantage of that. Previously it used work queue to
postpone work processing into always-process context.

> Unless I am misreading something we should just be able to remove the
> work queues and greatly simplify the connector code.
> 
> Something like:

Idea looks very good, thank you, but it misses structure changes
to eliminate now unneded members.

-- 
	Evgeniy Polyakov
