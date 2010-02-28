From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Why does connector use a work queue???
Date: Sun, 28 Feb 2010 12:10:35 -0800
Message-ID: <m1r5o5azpg.fsf@fess.ebiederm.org>
References: <m1pr3qcbk1.fsf@fess.ebiederm.org>
	<20100228195243.GA15976@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100228195243.GA15976@ioremap.net> (Evgeniy Polyakov's message of "Sun\, 28 Feb 2010 22\:52\:43 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <zbr@ioremap.net> writes:

> On Sat, Feb 27, 2010 at 06:57:02PM -0800, Eric W. Biederman (ebiederm@xmission.com) wrote:
>> These days netlink callbacks for messages happen in the context of the
>> process who sent the message.  Things like permission checks are much
>> more complicated if we don't use that process context.
>> 
>> I was looking at removing NETLINK_CB(skb).eff_cap but I discovered
>> that connected takes the netlink messages, them from their
>> perfectly good process context, and puts the into a workqueue
>> for reasons that are not apparent to me.
>
> Netlink was made synchronous rather recently and connector was not
> changed to take advantage of that. Previously it used work queue to
> postpone work processing into always-process context.

I suspected it was something like that but I want to be certain.

>> Unless I am misreading something we should just be able to remove the
>> work queues and greatly simplify the connector code.
>> 
>> Something like:
>
> Idea looks very good, thank you, but it misses structure changes
> to eliminate now unneded members.

Right. I didn't trust myself to write a patch that would rip out half
of the connector code until I understood what the constraints were.

Eric
