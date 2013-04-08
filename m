From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH 2/2] bonding: fix bonding_masters race condition in bond
 unloading
Date: Mon, 8 Apr 2013 11:24:44 +0200
Message-ID: <20130408092444.GB1757@redhat.com>
References: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
 <1365245678-4455-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934484Ab3DHJZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 05:25:10 -0400
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

Given that this bug is in net tree and we really need a fix to continue
development, adding a second device removal loop is not a big deal
actually, and this can be addressed correctly later in net-next. It's a
really rare bug anyway, and the second loop most of the time would be a
simple no-op, as Nikolay correctly stated.

Acked-by: Veaceslav Falico <vfalico@redhat.com>
