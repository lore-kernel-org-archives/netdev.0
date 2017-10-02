From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv4 iproute2 2/2] lib/libnetlink: update rtnl_talk to
 support malloc buff at run time
Date: Mon, 2 Oct 2017 10:37:08 -0700
Message-ID: <20171002103708.0572704b@xeon-e3>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
        <1506605626-1744-3-git-send-email-haliu@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: Hangbin Liu <haliu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:44254 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbdJBRhL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 13:37:11 -0400
Received: by mail-pg0-f48.google.com with SMTP id b1so1824805pge.1
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 10:37:11 -0700 (PDT)
In-Reply-To: <1506605626-1744-3-git-send-email-haliu@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Sep 2017 21:33:46 +0800
Hangbin Liu <haliu@redhat.com> wrote:

> From: Hangbin Liu <liuhangbin@gmail.com>
> 
> This is an update for 460c03f3f3cc ("iplink: double the buffer size also in
> iplink_get()"). After update, we will not need to double the buffer size
> every time when VFs number increased.
> 
> With call like rtnl_talk(&rth, &req.n, NULL, 0), we can simply remove the
> length parameter.
> 
> With call like rtnl_talk(&rth, nlh, nlh, sizeof(req), I add a new variable
> answer to avoid overwrite data in nlh, because it may has more info after
> nlh. also this will avoid nlh buffer not enough issue.
> 
> We need to free answer after using.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---

Most of the uses of rtnl_talk() don't need to this peek and dynamic sizing.
Can only those places that need that be targeted?
