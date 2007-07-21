From: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 1/1] Allow LSM to use IP address/port number.
Date: Sat, 21 Jul 2007 10:57:35 +0900
Message-ID: <200707211057.ACE39835.WUNtGEPSOFF@I-love.SAKURA.ne.jp>
References: <20070709160538.289d8ac2@freepuppy.rosehill.hemminger.net>
	<Line.LNX.4.64.0707091940450.10029@d.namei>
	<200707210011.HBI60217.FUNOWSFPGEt@I-love.SAKURA.ne.jp>
	<Line.LNX.4.64.0707201124070.7319@d.namei>
	<46A0D853.30803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: kaber@trash.net, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([220.111.47.146]:52631 "EHLO
	smtp.wine.ocn.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbXGUB5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 21:57:32 -0400
In-Reply-To: <46A0D853.30803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello.

Patrick McHardy wrote:
> Quoting Tetsuo:
> > > So, my approach is not using security context associated with a socket
> > > but security context associated with a process.
> Isn't the socket context derived from the process context?
Not so regarding my case.

static int smack_sk_alloc_security(struct sock *sk, int family, gfp_t priority)
{
	sk->sk_security = current->security;
	return 0;
}

will not help what I want to do.
So, I'm not planning to use "sk->sk_security".
I'm planning to use "current->security" at accept()/recvmsg() time.

What I want to do is to enforce subset of TCP Wrapper inside the kernel space
so that "IP/port based filtering for TCP and UDP is applied to ALL processes"
and "IP/port based filtering for TCP and UDP is not bypassed by processes that are
linked with TCP Wrapper library (even if accept()/recvmsg() syscalls are directly called)".

To receive source IP/port of a incoming packet, non-NULL msg->msg_name is needed for receiving them,
and I'm proposing modifications in net/socket.c .

Regards.
