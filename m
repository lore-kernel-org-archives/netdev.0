From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: Reported regression against commit a05d2ad
Date: Tue, 21 Jun 2011 14:38:50 -0600
Message-ID: <4E01015A.2030709@canonical.com>
References: <20110621201528.GB2249@herton-IdeaPad-Y430>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, lamont@canonical.com,
	sconklin@canonical.com, netdev@vger.kernel.org
To: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:4770 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757220Ab1FUUjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 16:39:12 -0400
In-Reply-To: <20110621201528.GB2249@herton-IdeaPad-Y430>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2011 02:15 PM, Herton Ronaldo Krzesinski wrote:
> Hi,
>
> after update to one of the latest 2.6.32.x stable kernels for Ubuntu, we
> got a regression report about timeout in tcp connections
> (https://launchpad.net/bugs/791512).
>
> We tried help reporter with a bisect process, but it was taking some
> time, so we reverted some suspect commits, until we isolated it to
> commit "af_unix: Only allow recv on connected seqpacket sockets."
>
> With only commit a05d2ad reverted, testing results so far indicate the
> issue doesn't happen.
>
> I'm unfamiliar with unix sockets code, so can't see at first why this
> commit in particular is causing problems, for now I can only say may be
> something at application level using unix sockets regressed with it (?).
> I'm just reporting it right now, and we plan to revert it for that kernel
> until more info is found about it.
>
> I'm adding reporter to CC (Lamont), in case more details are necessary
> etc.
>

I believe we're also homing in on the same regression in 2.6.38.6 
('af_unix: Only allow recv on connected seqpacket sockets.'). The 
functional part of the patch is:

+
+       if (sk->sk_state != TCP_ESTABLISHED)
+               return -ENOTCONN;
+
+       return unix_dgram_recvmsg(iocb, sock, msg, size, flags);

What happens with out of order receives? Would fragmentation have an impact?

rtg
-- 
Tim Gardner tim.gardner@canonical.com
