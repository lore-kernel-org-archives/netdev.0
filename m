From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] bridge: add notification over netlink when STP
 changes state
Date: Wed, 18 May 2011 08:39:48 -0700
Message-ID: <20110518083948.261ded68@nehalam>
References: <20110518081718.0b1fc390@nehalam>
	<4DD3E38C.30609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43360 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755314Ab1ERPju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 11:39:50 -0400
In-Reply-To: <4DD3E38C.30609@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 May 2011 08:19:40 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 05/18/2011 08:17 AM, Stephen Hemminger wrote:
> > The first netlink code in the bridge module was to notify
> > user space implementations of Spanning Tree Protocol about
> > new ports. It did not handle the case of kernel mode STP
> > changing states which could be useful for monitoring.
> >
> > This patch causes RTM_NEWLINK message to occur on kernel
> > transitions. It does not send message if request was from user
> > space STP, since that would cause reflection and break existing
> > API.
> 
> So one app monitoring the system won't get updates if another
> app makes changes?
> 
> Ben

For now, yes. Just don't want to break any existing users
which is more important.

-- 
