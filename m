From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [bisected] Re: [bug] networking broke, ssh: connect to port 22: Protocol error
Date: Wed, 6 Feb 2008 07:58:00 -0800 (PST)
Message-ID: <657224.72762.qm@web36615.mail.mud.yahoo.com>
References: <20080206133506.GA21202@elte.hu>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web36615.mail.mud.yahoo.com ([209.191.85.32]:33316 "HELO
	web36615.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751821AbYBFP6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 10:58:05 -0500
In-Reply-To: <20080206133506.GA21202@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--- Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > yeah, although various other upstream breakages prevented real long 
> > randconfig series in the past 2-3 days. I'd say it's either in this 
> > pull from your tree:
> 
> ok, i have bisected it down but the result made no sense, so i 
> double-checked it and noticed that the .config mutated during the test.
> 
> the diff below is the diff between the 'good' and 'bad' .config, with 
> this notable detail:
> 
>  @@ -2336,7 +2350,7 @@ CONFIG_SECURITY_NETWORK=y
>   CONFIG_SECURITY_CAPABILITIES=y
>   # CONFIG_SECURITY_FILE_CAPABILITIES is not set
>   # CONFIG_SECURITY_ROOTPLUG is not set
>  -# CONFIG_SECURITY_SMACK is not set
>  +CONFIG_SECURITY_SMACK=y
>   CONFIG_XOR_BLOCKS=m
>   CONFIG_ASYNC_CORE=m
>   CONFIG_ASYNC_MEMCPY=m
> 
> so i disabled CONFIG_SECURITY_SMACK, and viola, just 2 hours of hard 
> work later networking works on my testbox again :-/
> 
> And we have this 1 day old commit:
> 
>   commit e114e473771c848c3cfec05f0123e70f1cdbdc99
>   Author: Casey Schaufler <casey@schaufler-ca.com>
>   Date:   Mon Feb 4 22:29:50 2008 -0800
> 
>       Smack: Simplified Mandatory Access Control Kernel
> 
> that adds SMACK.
> 
> So unlike some other security modules like SELINUX, enabling SMACK 
> breaks un-aware userspace and breaks TCP networking?
> 
> I dont think that's expected behavior - and i'd definitely like to 
> enable SMACK in automated tests to check for regressions, etc.

As Stephen mentions later, Smack uses CIPSO. sshd does not like
any IP options because of traceroute, and must be built with that
check disabled with the current Smack version. I have been looking
at using unlabeled packets for the "ambient" label, it appears that
doing so would make life simpler. I will get right on it.

Application behavior in the presence of IP options isn't
always what I think it ought to be.


Casey Schaufler
casey@schaufler-ca.com
