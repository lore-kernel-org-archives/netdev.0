From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v2 net-next] bonding: don't call alb_set_slave_mac_addr()
 while atomic
Date: Mon, 17 Jun 2013 19:46:39 +0200
Message-ID: <51BF4B7F.5000101@redhat.com>
References: <1371490235-4448-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753603Ab3FQRrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 13:47:11 -0400
In-Reply-To: <1371490235-4448-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/06/13 19:30, Veaceslav Falico wrote:
> alb_set_slave_mac_addr() sets the mac address in alb mode via
> dev_set_mac_address(), which might sleep. It's called from
> alb_handle_addr_collision_on_attach() in atomic context (under
> read_lock(bond->lock)), thus triggering a bug.
> 
> Fix this by moving the lock inside alb_handle_addr_collision_on_attach().
> 
> v1->v2:
> As Nikolay Aleksandrov noticed, we can drop the bond->lock completely.
> Also, use bond_slave_has_mac(), when possible.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_alb.c | 40 +++++-----------------------------------
>  1 file changed, 5 insertions(+), 35 deletions(-)
> 

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
