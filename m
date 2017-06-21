From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Wed, 21 Jun 2017 11:33:20 -0700
Message-ID: <21644.1498070000@famine>
References: <1498068137-3550-1-git-send-email-michael.j.dilmore@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com
To: Michael J Dilmore <michael.j.dilmore@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1498068137-3550-1-git-send-email-michael.j.dilmore@gmail.com>
Content-ID: <21643.1498070000.1@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael J Dilmore <michael.j.dilmore@gmail.com> wrote:

>The function below contains a BUG_ON where no active slave is detected. The patch
>converts this to a WARN_ON to avoid crashing the kernel.
>
>Signed-off-by: Michael J Dilmore <michael.j.dilmore@gmail.com>
>---
> drivers/net/bonding/bond_options.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 1bcbb89..c4b4791 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -778,7 +778,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
> 		struct slave *old_active = rtnl_dereference(bond->curr_active_slave);
> 		struct slave *new_active = bond_slave_get_rtnl(slave_dev);
> 
>-		BUG_ON(!new_active);
>+		WARN_ON(!new_active);

	This is a reasonable idea in principle, but will require
additional changes to prevent dereferencing new_active if it is NULL
(which would happen just below this point in the code).

	-J

> 		if (new_active == old_active) {
> 			/* do nothing */
>-- 
>2.7.4
>

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
