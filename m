From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Thu, 07 Jan 2010 15:34:16 +0100
Message-ID: <m2ocl6m1av.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-5-git-send-email-sam@synack.fr>
	<4B41FE9D.2070708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob75-7-88-160-5-175.fbx.proxad.net ([88.160.5.175]:50996 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab0AGOeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 09:34:18 -0500
In-Reply-To: <4B41FE9D.2070708@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 15:43:41 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

>> +unsigned int event_hash_size = 16;
>> +module_param(event_hash_size, uint, 0600);
>> +MODULE_PARM_DESC(event_hash_size, "Set the size of the event hash table");
>> +
>> +unsigned int verdict_hash_size = 16;
>> +module_param(verdict_hash_size, uint, 0600);
>> +MODULE_PARM_DESC(verdict_hash_size, "Set the size of the verdict hash table");
>
> I can't see anything handling size changes after initialization,
> so there should probably use 0400.

right, here is a patch

thanks Patrick,
sam

commit af9c2157ecb130c1d08bcbeb121e4f50b3e40ab0
Author: Samir Bellabes <sam@synack.fr>
Date:   Tue Jan 5 17:58:42 2010 +0100

    snet: fixing permission of snet module's parameters
    
    the values of parameters are not changing after initialisation.
    So permissions should be 0400
    
    Noticed by Patrick McHardy <kaber@trash.net>
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/security/snet/snet_core.c b/security/snet/snet_core.c
index 6e2befc..bf55758 100644
--- a/security/snet/snet_core.c
+++ b/security/snet/snet_core.c
@@ -10,11 +10,11 @@
 #include "snet_utils.h"
 
 unsigned int snet_evh_size = 16;
-module_param(snet_evh_size, uint, 0600);
+module_param(snet_evh_size, uint, 0400);
 MODULE_PARM_DESC(snet_evh_size, "Set the size of the event hash table");
 
 unsigned int snet_vdh_size = 16;
-module_param(snet_vdh_size, uint, 0600);
+module_param(snet_vdh_size, uint, 0400);
 MODULE_PARM_DESC(snet_vdh_size, "Set the size of the verdict hash table");
 
 unsigned int snet_verdict_delay = 5;
@@ -22,7 +22,7 @@ module_param(snet_verdict_delay, uint, 0600);
 MODULE_PARM_DESC(snet_verdict_delay, "Set the timeout for verdicts in secs");
 
 unsigned int snet_verdict_policy = SNET_VERDICT_GRANT;	/* permissive by default */
-module_param(snet_verdict_policy, uint, 0600);
+module_param(snet_verdict_policy, uint, 0400);
 MODULE_PARM_DESC(snet_verdict_policy, "Set the default verdict");
 
 #ifdef CONFIG_SECURITY_SNET_DEBUG
