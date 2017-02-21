From: Tejun Heo <tj@kernel.org>
Subject: Re: Fw: [Bug 193911] New: net_prio.ifpriomap is not aware of the
 network namespace, and discloses all network interface
Date: Tue, 21 Feb 2017 15:41:52 -0500
Message-ID: <20170221204152.GA8260@htj.duckdns.org>
References: <20170203155330.06edece4@xeon-e3>
 <CAM_iQpVB_OvJy4Yz97MeOh9hNwm-mTG9aM1FWBpaaOmjroWvVw@mail.gmail.com>
 <20170206204728.GA23737@htj.duckdns.org>
 <87mvdrkz6u.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        xgao01@email.wm.edu
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:34502 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752932AbdBUUlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 15:41:55 -0500
Received: by mail-yw0-f179.google.com with SMTP id p77so3015579ywg.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 12:41:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87mvdrkz6u.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Feb 13, 2017 at 08:04:57AM +1300, Eric W. Biederman wrote:
> > Yeah, the whole thing never considered netns or delegation.  Maybe the
> > read function itself should probably filter on the namespace of the
> > reader?  I'm not completely sure whether trying to fix it won't cause
> > some of existing use cases to break.  Eric, what do you think?
> 
> Apologies for the delay I just made it back from vacation.

Hope you enjoyed the vacation.

> There are cases where we do look at the reader/opener of the  file, and
> it is a pain, almost always the best policy is to have the context fixed
> at mount time.
> 
> I don't see an obvious answer of what better semantics for this file
> should be.  Perhaps Docker can mount over this file on older kernels?
> 
> The namespace primitives that people build containers out of were never
> guaranteed not to leak the fact that you are in a container.  So a small
> essentially harmless information leak is not something I panic about.
> It is the setting up of the container itself that must know what the
> primitives do to ensure that leaks don't happen, if you want to avoid leaks.
> 
> That said if this controller/file does not consider netns and delegation
> I suspect the right thing to do is put it under CONFIG_BROKEN or
> possibly
> CONFIG_I_REALLY_NEED_THIS_SILLY_CODE_FOR_BACKWARDS_COMPATIBILITY
> aka CONFIG_STAGING and let the code age out of the kernel there.

I see.  Yeah, it is broken in terms of ns support.  Marking it BROKEN
from the config seems a bit drastic tho.

> If someone actually cares about this code and wants to fix it to do the
> something reasonable and is willing to dig through all of the subtleties
> I can help with that.  I may be wrong but the code feels like something
> that just isn't interesting enough to make it worth fixing.

The network part of cgroup v2 can do the same thing, doesn't have
these issues and can be used in conjunction with cgroup v1, so we
already have a way out of this.

I don't think we need to take an active action on it at this point.
People who need namespace support can adopt cgroup v2 without breaking
other things and I'm not sure there's enough benefit in marking the v1
features BROKEN at this point.

Thanks.

-- 
tejun
