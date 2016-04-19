From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 21:17:44 -0700
Message-ID: <1461039464.10638.150.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
	 <20160418.234137.26692086759328024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>, Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34126 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbcDSERq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 00:17:46 -0400
Received: by mail-pa0-f54.google.com with SMTP id r5so2087452pag.1
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 21:17:46 -0700 (PDT)
In-Reply-To: <20160418.234137.26692086759328024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 23:41 -0400, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Mon, 18 Apr 2016 14:10:19 -0700
> 
> > This patch adds a new RTM_GETSTATS message to query link stats via
> > netlink from the kernel. RTM_NEWLINK also dumps stats today, but
> > RTM_NEWLINK returns a lot more than just stats and is expensive in
> > some cases when frequent polling for stats from userspace is a
> > common operation.
> 
> I'm holding off on this until we sort out the 64-bit netlink
> attribute alignment issue.
> 
> Meanwhile, I'll some kind of a fix into the tree for the
> rtnl_fill_stats() change so that it doesn't cause unaligned
> accesses.

Also it looks like my previous feedback for sctp_get_sctp_info() has
been ignored.

<Quoting http://www.spinics.net/lists/netdev/msg372523.html >

info is not guaranteed to be aligned on 8 bytes.

You need to use put_unaligned()

Check commit ff5d749772018 ("tcp: beware of alignments in
tcp_get_info()") for details.

</quote>
