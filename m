From: Tejun Heo <tj@kernel.org>
Subject: Re: Fw: [Bug 193911] New: net_prio.ifpriomap is not aware of the
 network namespace, and discloses all network interface
Date: Mon, 6 Feb 2017 15:47:28 -0500
Message-ID: <20170206204728.GA23737@htj.duckdns.org>
References: <20170203155330.06edece4@xeon-e3>
 <CAM_iQpVB_OvJy4Yz97MeOh9hNwm-mTG9aM1FWBpaaOmjroWvVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        xgao01@email.wm.edu, "Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34538 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751517AbdBFUra (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 15:47:30 -0500
Received: by mail-yw0-f194.google.com with SMTP id v73so7943793ywg.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 12:47:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAM_iQpVB_OvJy4Yz97MeOh9hNwm-mTG9aM1FWBpaaOmjroWvVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sun, Feb 05, 2017 at 11:05:36PM -0800, Cong Wang wrote:
> > To be more specific, the read operation of net_prio.ifpriomap is handled by the
> > function read_priomap. Tracing from this function, we can find it invokes
> > for_each_netdev_rcu and set the first parameter as the address of init_net. It
> > iterates all network devices of the host regardless of the network namespace.
> > Thus, from the view of a container, it can read the names of all network
> > devices of the host.
> 
> I think that is probably because cgroup files don't provide a net pointer
> for the context, if so we probably need some API similar to
> class_create_file_ns().

Yeah, the whole thing never considered netns or delegation.  Maybe the
read function itself should probably filter on the namespace of the
reader?  I'm not completely sure whether trying to fix it won't cause
some of existing use cases to break.  Eric, what do you think?

Thanks.

-- 
tejun
