From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Mon, 30 Jul 2012 13:51:02 +0200
Message-ID: <1343649062.21269.23.camel@edumazet-glaptop>
References: <50160EEF.6050406@parallels.com>  <87pq7dh6b2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60246 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456Ab2G3LvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 07:51:07 -0400
Received: by eaak13 with SMTP id k13so1085388eaa.19
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2012 04:51:06 -0700 (PDT)
In-Reply-To: <87pq7dh6b2.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-30 at 03:49 -0700, Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
> 
> > Currently the RTM_NEWLINK results in -EOPNOTSUPP if the ifinfomsg->ifi_index
> > is not zero. I propose to allow requesting ifindices on link creation. This
> > is required by the checkpoint-restore to correctly restore a net namespace
> > (i.e. -- a container). The question what to do with pre-created devices such
> > as lo or sit fbdev is open, but for manually created devices this can be 
> > solved by this patch.
> 
> Have you walked through and found the locations where we still rely on
> ifindex being globally unique?
> 
> Last time I was working in this area there were serveral places where
> things were indexed by just the interface index.

Really ? This would be very strange.

AFAIK dev_new_index() is always called, even in the
dev_change_net_namespace() case if there is a conflict.

And dev_new_index() could use a pernet net->ifindex instead of a
shared/static one.
