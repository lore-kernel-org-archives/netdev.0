From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] separate SIOCGIFCONF from the rest of dev_ioctl()
Date: Mon, 26 Jun 2017 22:25:14 +0200
Message-ID: <1498508714.24675.5.camel@sipsolutions.net>
References: <20170626174033.GA10672@ZenIV.linux.org.uk>
         (sfid-20170626_194046_038743_EA9764C4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36770 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751403AbdFZUZS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 16:25:18 -0400
In-Reply-To: <20170626174033.GA10672@ZenIV.linux.org.uk> (sfid-20170626_194046_038743_EA9764C4)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-06-26 at 18:40 +0100, Al Viro wrote:

> 	Only two of dev_ioctl() callers may pass SIOCGIFCONF to it.
> Separating that codepath from the rest of dev_ioctl() allows both
> to simplify dev_ioctl() itself (all other cases work with struct
> ifreq *)
> *and* seriously simplify the compat side of that beast: all it takes
> is passing to inet_gifconf() an extra argument - the size of
> individual
> records (sizeof(struct ifreq) or sizeof(struct compat_ifreq)).  With
> dev_ifconf() called directly from sock_do_ioctl()/compat_dev_ifconf()
> that's easy to arrange.

No objection from me; however, I just introduced another special case
(in a bugfix for a >20yo bug ...) here:

https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/?id=68dd02d19c811ca8ea60220a9d73e13b4bdad73a

It would perhaps make sense to also pull that out into the caller,
which could also get rid of the stupid way the #ifdef is placed in
sock_ioctl(). For compat, it's already pulled out anyway, even a level
up than where you're calling it for SIOCGIFCONF - might make sense to
put the wext stuff into compat_sock_ioctl_trans() too.

johannes
