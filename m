From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipip: fix a regression in ioctl
Date: Mon, 01 Jul 2013 10:11:21 +0800
Message-ID: <1372644681.2974.12.camel@cr0>
References: <1372479115-7003-1-git-send-email-amwang@redhat.com>
	 <CALnjE+qoo3D6YDpZogPq8LOJLZxoOTLa73WJFHnH2MbnFB2f7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab3GACL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jun 2013 22:11:29 -0400
In-Reply-To: <CALnjE+qoo3D6YDpZogPq8LOJLZxoOTLa73WJFHnH2MbnFB2f7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 20:43 -0700, Pravin Shelar wrote:
> On Fri, Jun 28, 2013 at 9:11 PM, Cong Wang <amwang@redhat.com> wrote:
> > From: Cong Wang <amwang@redhat.com>
> >
> > This is a regression introduced by
> > commit fd58156e456d9f68fe0448 (IPIP: Use ip-tunneling code.)
> >
> > Similar to GRE tunnel, previously we only check the parameters
> > for SIOCADDTUNNEL and SIOCCHGTUNNEL, after that commit, the
> > check is moved for all commands.
> >
> > So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.
> >
> > Also, the check for i_key, o_key etc. is suspicious too,
> > which did not exist before.
> >
> This check is sanity check since ipip is not suppose to have these
> parameters set, generic layer do allow all parameters.
> Earlier ipip was not using generic layer, therefore that check was not present.

So, if old code doesn't reject this case with EINVAL, then your change
_does_ break user-space applications... no matter whether ipip is
supposed to have these parameters.
