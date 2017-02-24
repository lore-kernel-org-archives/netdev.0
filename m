From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: VXLAN RCU error
Date: Fri, 24 Feb 2017 11:30:05 -0800
Message-ID: <CAM_iQpWuXzNHNiwjX0V8FrEaPMHsaYX-Tm3QKHJqTxLuKqZ1xA@mail.gmail.com>
References: <20170222142745.31c5f75e@cakuba.netronome.com> <20170222203031.45513e4c@cakuba.netronome.com>
 <20170223002025.2d2d3c4e@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34997 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbdBXTa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 14:30:27 -0500
Received: by mail-wm0-f50.google.com with SMTP id v186so22204145wmd.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 11:30:26 -0800 (PST)
In-Reply-To: <20170223002025.2d2d3c4e@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 12:20 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
>
> Ugh.  Looks like this may not work even if it makes the splat go away.
> synchronize_net() doesn't seem to wait for the _bh() flavor of RCU, so
> we need to add syncronize_rcu_bh() call before freeing the socket or do
> a normal rcu_read_lock()/unlock() on the fast path.  Any RCU experts
> want to comment? :)

But rcu_read_lock_bh() is enforced by upper layer, __dev_queue_xmit(),
I am afraid you can't change it.

Does changing these kfree() to kfree_rcu() work too since there is no
kfree_rcu_bh()?
