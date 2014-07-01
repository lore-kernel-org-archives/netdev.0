From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/2] send process status in SCM_PROCINFO
Date: Tue, 01 Jul 2014 16:31:53 -0700 (PDT)
Message-ID: <20140701.163153.30109595101601494.davem@davemloft.net>
References: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kyungmin.park@samsung.com,
	juho80.son@samsung.com, b.zolnierkie@samsung.com,
	jkaluza@redhat.com, luto@amacapital.net
To: p.wilczek@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbaGAXbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 19:31:55 -0400
In-Reply-To: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Piotr Wilczek <p.wilczek@samsung.com>
Date: Thu, 26 Jun 2014 14:55:52 +0200

> Server-like processes in many cases need credentials and other
> metadata of the peer, to decide if the calling process is allowed to
> request a specific action, or the server just wants to log away this
> type of information for auditing tasks.
> 
> The current practice to retrieve such process metadata is to look that
> information up in procfs with the $PID received over SCM_CREDENTIALS.
> This is sufficient for long-running tasks, but introduces a race which
> cannot be worked around for short-living processes; the calling
> process and all the information in /proc/$PID/ is gone before the
> receiver of the socket message can look it up.
> 
> Changes introduced in this patchset can also increase performance
> of such server-like processes, because current way of opening and
> parsing /proc/$PID/* files is much more expensive than receiving these
> metadata using SCM.
> 
> As an example, this patch set improves systemd-journald performance
> by about 20%. Generally, performance improvement depends on how heavily
> procfs is read the calling process.
> http://comments.gmane.org/gmane.comp.sysutils.systemd.devel/19467
> 
> This patch set is split in two patches:
> - the first adds library to retrive process information without
> dependency on procfs.
> - the second introduces a new SCM type called SCM_PROCINFO to optionally
> allow the direct attaching of process status to SCM.

I really would like someone smarter than me to review the security
implications et al. of these changes before I apply them.

Andy?  Maybe you have an opinion?
