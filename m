From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/4] Make xfrm usable by 32-bit programs
Date: Mon, 23 Jan 2017 10:35:17 +0100
Message-ID: <20170123093517.GM3541@gauss.secunet.com>
References: <20170121000507.34381-1-cernekee@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
        <paul@paul-moore.com>, <sds@tycho.nsa.gov>,
        <eparis@parisplace.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>, <fw@strlen.de>,
        <fan.du@windriver.com>, <dianders@chromium.org>,
        <dtor@chromium.org>
To: Kevin Cernekee <cernekee@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50514 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbdAWJfU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 04:35:20 -0500
Content-Disposition: inline
In-Reply-To: <20170121000507.34381-1-cernekee@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 20, 2017 at 04:05:03PM -0800, Kevin Cernekee wrote:
> Several of the xfrm netlink and setsockopt() interfaces are not usable
> from a 32-bit binary running on a 64-bit kernel due to struct padding
> differences.  This has been the case for many, many years[0].  This
> patch series deprecates the broken netlink messages and replaces them
> with packed structs that are compatible between 64-bit and 32-bit
> programs.  It retains support for legacy user programs (i.e. anything
> that is currently working today), and allows legacy support to be
> compiled out via CONFIG_XFRM_USER_LEGACY if it becomes unnecessary in
> the future.

This would mean that we have to maintain two APIs from now on.
This is something I really want to avoid because it is almost
impossible to get rid of the old one.

> 
> Earlier attempts at fixing the problem had implemented a compat layer.
> A compat layer is helpful because it avoids the need to recompile old
> user binaries, but there are many challenges involved in implementing
> it.  I believe a compat layer is of limited value in this instance
> because anybody who really needed to solve the problem without
> recompiling their binaries has almost certainly found another solution
> in the ~7 years since the compat patches were first proposed.
> 
> A benefit of this approach is that long-term, the broken netlink messages
> will no longer be used.  A drawback is that in the short term, user
> programs that want to adopt the new message formats will require a
> modern kernel.  Projects like strongSwan and iproute2 bundle the xfrm.h
> header inside their own source trees, so they will need to make a
> judgment call on when to remove support for kernels that do not support
> the new messages.  And programs built against the new kernel headers
> will not work on old kernels.

So this creates new incompatibilities what is another argument against
this approach. If you really need this, try to implement a full compat
layer. I think this is the only sane solution for this.
