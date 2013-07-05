From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH iproute2] ipbatch: fix use of 'ip netns exec'
Date: Fri, 5 Jul 2013 21:49:13 +0100
Message-ID: <1373057353.1913.55.camel@bwh-desktop.uk.level5networks.com>
References: <1373040345-11116-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>,
	<junwei.zhang@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47257 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab3GEUtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 16:49:18 -0400
In-Reply-To: <1373040345-11116-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-05 at 18:05 +0200, Nicolas Dichtel wrote:
> From: JunweiZhang <junwei.zhang@6wind.com>
> 
> execvp() does not return when the command succeed, hence all commands in the
> batch file after the line 'ip netns exec' are not executed.
>
> Let's fork before calling execvp().

A Unix shell forks every command it runs, so why should ip do this too?

[...]
> +       return WIFEXITED(status) ? EXIT_SUCCESS : EXIT_FAILURE;
[...]

So you throw away the original exit code of the child process.

I suspect your actual problem has to do with the exit code of the child,
and your shell script contains 'set -e'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
