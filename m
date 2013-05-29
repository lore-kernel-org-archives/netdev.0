From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Wed, 29 May 2013 12:01:12 +0800
Message-ID: <1369800072.12227.5.camel@cr0>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768Ab3E2EBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 00:01:19 -0400
In-Reply-To: <1369739242-5944-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-28 at 19:07 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> In commit 553675fb5e9ce3d71a (vxlan: listen on multiple ports),
> we use kfree_rcu() to free ->vn_sock, but a) there is no use
> of RCU API to access this filed, b) RCU is not enough to do refcnt
> here, because in vxlan_leave_group() we drop RTNL lock before
> locking the socket, it could be possible that this field is
> freed during this period.
> 
> So, instead making things complex, just do basic refcnt for
> the ->vn_sock, like we do for others.

BTW, this patch fixes a real crash when I test vxlan over IPv6, although
I can't reproduce it with IPv4.
