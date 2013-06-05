From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next v1 3/3] igmp: convert RTNL lock to a spinlock
Date: Tue, 4 Jun 2013 20:52:44 -0700
Message-ID: <20130604205244.7d9436b2@nehalam.linuxnetplumber.net>
References: <1370403211-6851-1-git-send-email-amwang@redhat.com>
	<1370403211-6851-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:60749 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890Ab3FEDws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 23:52:48 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so217606pdc.19
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 20:52:48 -0700 (PDT)
In-Reply-To: <1370403211-6851-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  5 Jun 2013 11:33:31 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> It is not necessary to hold RTNL lock to protect mc_list,
> at least IPv6 mcast is using a local spinlock, IPv4 can do
> this too. This patch converts RTNL lock+RCU to spinlock+RCU,
> so that vxlan does not need to release RTNL lock before
> calling mcast API's.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Not necessary, I have an alternate fix for vxlan.
