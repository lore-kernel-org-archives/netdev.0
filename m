From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Sat, 16 Jan 2010 02:59:38 +0100
Message-ID: <m24ommhks5.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-8-git-send-email-sam@synack.fr>
	<4B420464.3040301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B420464.3040301@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 16:08:20 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>> +atomic_t snet_num_listeners = ATOMIC_INIT(0);
>
> The num_listeners seem to be redundant as you only support a
> single listener anyways, whose presence is indicated by
> snet_nl_pid != 0.

I simplified the code, by removing the variable snet_num_listeners and
use the value of snet_nl_pid
 * if snet_nl_pid == 0, then there is no userspace listening application 
 * if snet_nl_pid > 0, then its value is the PID of the listening
   application

In the same time, I deleted the check on a listener for this operations
on verdict : snet_nl_version, snet_nl_insert, snet_nl_remove,
snet_nl_flush, snet_nl_verdict_delay. 
In this way, it's possible to execute this operations and get events in
the same time (which means have a listeners)

Patrick, thanks again for reviewing

sam
