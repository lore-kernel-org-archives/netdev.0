From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/6] net: sctp: fix information leaks in
 ulpevent layer
Date: Mon, 14 Jul 2014 14:19:45 -0700 (PDT)
Message-ID: <20140714.141945.278096782065573850.davem@davemloft.net>
References: <1405189840-31171-1-git-send-email-dborkman@redhat.com>
	<1405189840-31171-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geirola@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756896AbaGNVTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 17:19:46 -0400
In-Reply-To: <1405189840-31171-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat, 12 Jul 2014 20:30:35 +0200

> While working on some other SCTP code, I noticed that some
> structures shared with user space are leaking uninitialized
> stack or heap buffer. In particular, struct sctp_sndrcvinfo
> has a 2 bytes hole between .sinfo_flags and .sinfo_ppid that
> remains unfilled by us in sctp_ulpevent_read_sndrcvinfo() when
> putting this into cmsg. But also struct sctp_remote_error
> contains a 2 bytes hole that we don't fill but place into a skb
> through skb_copy_expand() via sctp_ulpevent_make_remote_error().
 ...
> Fix this by setting both to 0 before filling them out. We also
> have other structures shared between user and kernel space in
> SCTP that contains holes (e.g. struct sctp_paddrthlds), but we
> copy that buffer over from user space first and thus don't need
> to care about it in that cases.
> 
> While at it, we can also remove lengthy comments copied from
> the draft, instead, we update the comment with the correct RFC
> number where one can look it up.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied to 'net' and queued up for -stable.

I'll get to the rest of this series after I next merge net into
net-next, thanks.
