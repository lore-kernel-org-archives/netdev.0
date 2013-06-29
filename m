From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] gre: fix a regression in ioctl
Date: Sat, 29 Jun 2013 11:33:42 +0800
Message-ID: <1372476822.29178.3.camel@cr0>
References: <1372471480-28992-1-git-send-email-amwang@redhat.com>
	 <1372472672-1900-1-git-send-email-amwang@redhat.com>
	 <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428Ab3F2Ddu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 23:33:50 -0400
In-Reply-To: <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-28 at 20:28 -0700, Pravin Shelar wrote:
> On Fri, Jun 28, 2013 at 7:24 PM, Cong Wang <amwang@redhat.com> wrote:
> > From: Cong Wang <amwang@redhat.com>
> >
> > When testing GRE tunnel, I got:
> >
> >  # ip tunnel show
> >  get tunnel gre0 failed: Invalid argument
> >  get tunnel gre1 failed: Invalid argument
> >
> > This is a regression introduced by commit c54419321455631079c7d
> > ("GRE: Refactor GRE tunneling code.") because previously we
> > only check the parameters for SIOCADDTUNNEL and SIOCCHGTUNNEL,
> > after that commit, the check is moved for all commands.
> >
> 
> right, that API got changed. But these checks can not be added to
> generic ip_tunnel layer, which is also used by other tunnel modules.
> Can you keep that check in ip_gre module but do it only for add and
> del tunnel commands?

Yeah.

BTW, ipip has the same bug... I will send a patch for ipip too.
