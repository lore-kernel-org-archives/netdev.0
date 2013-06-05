From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v1 3/3] igmp: convert RTNL lock to a spinlock
Date: Wed, 05 Jun 2013 13:21:59 +0800
Message-ID: <1370409719.2609.6.camel@cr0>
References: <1370403211-6851-1-git-send-email-amwang@redhat.com>
	 <1370403211-6851-3-git-send-email-amwang@redhat.com>
	 <20130604205244.7d9436b2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243Ab3FEFWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 01:22:07 -0400
In-Reply-To: <20130604205244.7d9436b2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-04 at 20:52 -0700, Stephen Hemminger wrote:
> On Wed,  5 Jun 2013 11:33:31 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > From: Cong Wang <amwang@redhat.com>
> > 
> > It is not necessary to hold RTNL lock to protect mc_list,
> > at least IPv6 mcast is using a local spinlock, IPv4 can do
> > this too. This patch converts RTNL lock+RCU to spinlock+RCU,
> > so that vxlan does not need to release RTNL lock before
> > calling mcast API's.
> > 
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Not necessary, I have an alternate fix for vxlan.
> 

If you mean your _ip_mc_join_group() patch, I am sure it doesn't work.
Besides lack of lock_sock(), the locking order needs to be fixed too.
Trust me, I tried it, the _final_ patch is ugly.
