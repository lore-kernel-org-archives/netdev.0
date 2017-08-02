From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: sysctl, argument parsing, possible bug
Date: Wed, 2 Aug 2017 23:53:54 +0200
Message-ID: <20170802215354.GN18884@wotan.suse.de>
References: <CAKv20-VuR4J0PJOOfsRmEPMhB+vKYMdPsp5wDgVkoYwrHxgLGw@mail.gmail.com>
 <CAM_iQpXtHACnD8kmmHd4bcg+Khy5Y0K=HMmc08avTSHov4zN1A@mail.gmail.com>
 <CAKv20-VFcdZti=4a6QzVJH0wAYGpqo2umktRPr19tv+btSZY_w@mail.gmail.com>
 <CAM_iQpV8rJOxvA+hT4Dfs_+sJv5N9ZVv5DCgYDxjpvr2X124ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Massimo Sala <massimo.sala.71@gmail.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Kees Cook <keescook@chromium.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpV8rJOxvA+hT4Dfs_+sJv5N9ZVv5DCgYDxjpvr2X124ww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 02:54:51PM -0700, Cong Wang wrote:
> On Tue, Aug 1, 2017 at 2:34 PM, Massimo Sala <massimo.sala.71@gmail.com> wrote:
> > Do you confirm it is a sysctl parsing bug ?
> >
> > Bosybox handles these cases, so I think also standalone sysctl have to.
> >
> > Or at least someone must update sysctl docs / MAN about this.
> >
> 
> Maybe, sysctl seems (I never look into it) just to interpret dot as
> a separator, unless it reads from the /proc/sys/ directory, it can
> not know eth0.100 is actually a netdev name.

Using echo or sysctl -w works for me, try upgrading your procps,
I have procps-3.3.12. Busybox sysctl fails though, so it would
seems this is an issue with busybox, go fix that.

With procps-3.3.12.:

Setting:

ergon:~ # cat /proc/sys/net/ipv4/conf/eth0.100/forwarding 
1

ergon:~ # sysctl -w net.ipv4.conf.eth0/100.forwarding=0
net.ipv4.conf.eth0/100.forwarding = 0

ergon:~ # cat /proc/sys/net/ipv4/conf/eth0.100/forwarding 
0

Querying:

ergon:~ # sysctl net.ipv4.conf.eth0/100.forwarding
net.ipv4.conf.eth0/100.forwarding = 0

With busybox:

ergon:~ # busybox-static sysctl net.ipv4.conf.eth0/100.forwarding
sysctl: error: 'net.ipv4.conf.eth0.100.forwarding' is an unknown key

  Luis
