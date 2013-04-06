From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH 2/2] bonding: fix bonding_masters race condition in bond
 unloading
Date: Sat, 6 Apr 2013 15:50:20 +0200
Message-ID: <20130406135020.GA18246@redhat.com>
References: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
 <1365245678-4455-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422899Ab3DFNul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 09:50:41 -0400
Content-Disposition: inline
In-Reply-To: <1365245678-4455-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 06, 2013 at 12:54:38PM +0200, Nikolay Aleksandrov wrote:
>While the bonding module is unloading, it is considered that after
>rtnl_link_unregister all bond devices are destroyed but since no
>synchronization mechanism exists, a new bond device can be created
>via bonding_masters before unregister_pernet_subsys which would
>lead to multiple problems (e.g. NULL pointer dereference, wrong RIP,
>list corruption).
>
>This patch fixes the issue by removing any bond devices left in the
>netns after bonding_masters is removed from sysfs.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_main.c | 9 +++++++++
> 1 file changed, 9 insertions(+)
>

I'm still thinking that's it's not the best way of fixing it
(remove_devices(); remove_sysfs(); remove_devices()) - but given that I
can't come up with anything better and my first fix didn't actually work -
I'm ok with your patch.
