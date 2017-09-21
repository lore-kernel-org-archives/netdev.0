From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCHv3 iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Thu, 21 Sep 2017 09:34:20 +0200
Message-ID: <20170921073420.dcoipli2sxy3bmnx@unicorn.suse.cz>
References: <1505871820-31580-1-git-send-email-liuhangbin@gmail.com>
 <1505871820-31580-2-git-send-email-liuhangbin@gmail.com>
 <20170920095605.1ea527fc@xeon-e3>
 <20170921072002.GM5465@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44236 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751588AbdIUHeY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 03:34:24 -0400
Content-Disposition: inline
In-Reply-To: <20170921072002.GM5465@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 03:20:02PM +0800, Hangbin Liu wrote:
> 
> Or maybe we can set buf_len very small first. Then it will force to realloc at
> the second time. And the code would like
> 
> 	int buf_len = 16;
> 	bufp = realloc(buf, buf_len);
> 	/* check bufp and set msg */
> 
> 	len = recvmsg(fd, msg, flag);
> 	/* check len */
> 
> 	buf_len = len;
> 	bufp = realloc(buf, buf_len);
> 	/* check bufp and set msg */
> 
> 	len = recvmsg(fd, msg, flag);
> 	/* check len */
> 
> What do you think?

I will have to check but IIRC it might be possible to use zero length
for the peek to only check the length which could help you to avoid both
the reallocation and copying the same data from kernel to userspace
twice.

Michal Kubecek
