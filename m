From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Remove broken netfilter binary sysctls from bridging
 code
Date: Tue, 25 Sep 2007 09:12:03 -0700
Message-ID: <20070925091203.371879e2@fujitsu-loaner>
References: <20070918011841.2381bd93.akpm@linux-foundation.org>
	<20070921020554.GE31759@nineveh.local>
	<m1fy18k5ru.fsf@ebiederm.dsl.xmission.com>
	<46F7EC0A.9030506@trash.net>
	<20070924131458.0daa4562@freepuppy.rosehill>
	<46F8897C.5010504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41113 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbXIYQMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 12:12:14 -0400
In-Reply-To: <46F8897C.5010504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Sep 2007 06:07:24 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > On Mon, 24 Sep 2007 18:55:38 +0200
> > Patrick McHardy <kaber@trash.net> wrote:
> > 
> >>Eric W. Biederman wrote:
> >>
> >>>A really good fix would be to remove the binary side and then to
> >>>modify brnf_sysctl_call_tables to allocate a temporary ctl_table
> >>>and integer on the stack and only set ctl->data after we have
> >>>normalized the written value.  But since in practice nothing cares
> >>>about the race a better fix probably isn't worth it.
> >>
> >>
> >>I seem to be missing something, the entire brnf_sysctl_call_tables
> >>thing looks purely cosmetic to me, wouldn't it be better to simply
> >>remove it?
> > 
> > 
> > I agree, removing seems like a better option.  But probably need to
> > go through a 3-6mo warning period, since sysctl's are technically
> > an API.
> 
> 
> I meant removing brnf_sysctl_call_tables function, not the sysctls
> themselves, all it does is change values != 0 to 1. Or did you
> actually mean that something in userspace might depend on reading
> back the value 1 after writing a value != 0?

I was going farther, because don't really see the value of having
a sysctl for this. It seems better to just not load filters if
they aren't going to be used. Having another enable/disable hook
just adds needless complexity.
