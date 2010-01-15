From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Fri, 15 Jan 2010 10:15:57 +0100
Message-ID: <m2k4vjhgoi.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-8-git-send-email-sam@synack.fr>
	<4B420464.3040301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B420464.3040301@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 16:08:20 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>> +static struct genl_ops snet_genl_ops[] = {
>> +	{
>> +		.cmd		= SNET_C_VERSION,
>> +		.flags		= GENL_ADMIN_PERM,
>> +		.policy		= snet_genl_policy,
>> +		.doit		= snet_nl_version,
>> +		.dumpit		= NULL,
>
> The NULL initializations aren't neccessary.
>
[...]
Instead of dropping lines with the NULL initializations, I reduced the
code with a declaration macro

Patricks, thanks
sam
 
commit f8539d466dbe081b35f6813cfedd91947615bee9
Author: Samir Bellabes <sam@synack.fr>
Date:   Fri Jan 15 09:53:09 2010 +0100

    snet: reducing code by using macros to define snet_genl_ops
    
    This patch introduces the macro SNET_GENL_OPS. This reduces the code of the
    declaration struct genl_ops snet_genl_ops[]
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/security/snet/snet_netlink.c b/security/snet/snet_netlink.c
index e108e7a..ba6a26d 100644
--- a/security/snet/snet_netlink.c
+++ b/security/snet/snet_netlink.c
@@ -400,70 +400,33 @@ out:
 	return ret;
 }
 
+#define SNET_GENL_OPS(_cmd, _flags, _policy, _op, _opname)		\
+	{							\
+		.cmd	= _cmd,					\
+		.flags	= _flags,				\
+		.policy	= _policy,				\
+		._op	= snet_nl_##_opname,			\
+	}
+
 static struct genl_ops snet_genl_ops[] = {
-	{
-		.cmd		= SNET_C_VERSION,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= snet_nl_version,
-		.dumpit		= NULL,
-	},
-	{
-		.cmd		= SNET_C_REGISTER,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= snet_nl_register,
-		.dumpit		= NULL,
-	},
-	{
-		.cmd		= SNET_C_UNREGISTER,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= snet_nl_unregister,
-		.dumpit		= NULL,
-	},
-	{
-		.cmd		= SNET_C_INSERT,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= snet_nl_insert,
-		.dumpit		= NULL,
-	},
-	{
-		.cmd		= SNET_C_REMOVE,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= snet_nl_remove,
-		.dumpit		= NULL,
-	},
-	{
-		.cmd		= SNET_C_FLUSH,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= snet_nl_flush,
-		.dumpit		= NULL,
-	},
-	{
-		.cmd		= SNET_C_LIST,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= NULL,
-		.dumpit		= snet_nl_list,
-	},
-	{
-		.cmd		= SNET_C_VERDICT,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= snet_nl_verdict,
-		.dumpit		= NULL,
-	},
-	{
-		.cmd		= SNET_C_VERDICT_DELAY,
-		.flags		= GENL_ADMIN_PERM,
-		.policy		= snet_genl_policy,
-		.doit		= snet_nl_verdict_delay,
-		.dumpit		= NULL,
-	},
+	SNET_GENL_OPS(SNET_C_VERSION, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, version),
+	SNET_GENL_OPS(SNET_C_REGISTER, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, register),
+	SNET_GENL_OPS(SNET_C_UNREGISTER, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, unregister),
+	SNET_GENL_OPS(SNET_C_INSERT, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, insert),
+	SNET_GENL_OPS(SNET_C_REMOVE, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, remove),
+	SNET_GENL_OPS(SNET_C_FLUSH, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, flush),
+	SNET_GENL_OPS(SNET_C_REGISTER, GENL_ADMIN_PERM, snet_genl_policy,
+		      dumpit, list),
+	SNET_GENL_OPS(SNET_C_REGISTER, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, verdict),
+	SNET_GENL_OPS(SNET_C_VERDICT_DELAY, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, verdict_delay),
 };
 
 static __init int snet_netlink_init(void)
