From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] netpoll: add some missing __rcu marks in
 several places
Date: Sat, 16 Feb 2013 11:16:27 +0800
Message-ID: <1360984587.12539.2.camel@cr0>
References: <20130213223935.122d035b@nehalam.linuxnetplumber.net>
	 <1360831039-11418-1-git-send-email-amwang@redhat.com>
	 <20130214.132054.2237485951582283881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, vyasevic@redhat.com,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027Ab3BPDQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 22:16:40 -0500
In-Reply-To: <20130214.132054.2237485951582283881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 13:20 -0500, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Thu, 14 Feb 2013 16:37:19 +0800
> 
> > From: Cong Wang <amwang@redhat.com>
> > 
> > This fixes sparse warnings like the one below:
> > 
> > drivers/net/team/team.c:953:25: warning: incorrect type in return expression (different address spaces)
> > drivers/net/team/team.c:953:25:    expected struct netpoll_info *
> > drivers/net/team/team.c:953:25:    got struct netpoll_info [noderef] <asn:4>*npinfo
> > 
> > Cc: Jiri Pirko <jiri@resnulli.us>
> > Cc: Vlad Yasevich <vyasevic@redhat.com>
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> This is a very confusing patch submission.
> 
> You're posting a "v2" of a patch but with a completely different Subject
> line so that it's hard, without looking into the details of the patch,
> to determine what this patch is a "v2" of.
> 
> You've also not addressed Stephen's feedback about the lack of an
> rcu_dereference() in these routines you've added __rcu annotations
> to.
> 
> I'm tossing all versions of this patch, therefore.

The reason is we don't dereference ->npinfo pointer, we just check if it
is NULL, so doesn't need to call rcu_dereference(). Or am I missing
anything?

Thanks.
