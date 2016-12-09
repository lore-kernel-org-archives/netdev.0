From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Fri, 9 Dec 2016 06:41:44 +0000
Message-ID: <20161209064144.GZ1555@ZenIV.linux.org.uk>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk>
 <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 08, 2016 at 10:32:00PM -0800, Cong Wang wrote:

> > Why do we do autobind there, anyway, and why is it conditional on
> > SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
> > to sending stuff without autobind ever done - just use socketpair()
> > to create that sucker and we won't be going through the connect()
> > at all.
> 
> In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
> not SOCK_STREAM.

Yes, I've noticed.  What I'm asking is what in there needs autobind triggered
on sendmsg and why doesn't the same need affect the SOCK_STREAM case?

> I guess some lock, perhaps the u->bindlock could be dropped before
> acquiring the next one (sb_writer), but I need to double check.

Bad idea, IMO - do you *want* autobind being able to come through while
bind(2) is busy with mknod?
