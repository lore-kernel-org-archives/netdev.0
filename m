From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Tue, 13 Jun 2017 08:16:56 +0200
Message-ID: <20170613061656.GF18283@breakpoint.cc>
References: <20170530093812.10712-1-fw@strlen.de>
 <87y3tcj3n7.fsf@xmission.com>
 <20170601085259.GA6067@breakpoint.cc>
 <CAM_iQpXgrQcbrQsMVoomcsHtk4JffRjJ27FLRoignndAzFVkug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        netfilter-devel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45888 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752285AbdFMGRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 02:17:35 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpXgrQcbrQsMVoomcsHtk4JffRjJ27FLRoignndAzFVkug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Jun 1, 2017 at 1:52 AM, Florian Westphal <fw@strlen.de> wrote:
> > Joe described it nicely, problem is that after unload we may have
> > conntracks that still have a nf_conn_help extension attached that
> > has a pointer to a structure that resided in the (unloaded) module.
> 
> Why not hold a refcnt for its module?

That would work as well.

I'm not sure its nice to disallow rmmod of helper modules if they are
used by a connection however.

Right now you can "rmmod nf_conntrack_foo" at any time and this should
work just fine without first having to flush affected conntracks
manually.
