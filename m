From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: xfrm: Can "struct netlbl_audit" be killed?
Date: Thu, 24 Apr 2014 20:51:35 +0900
Message-ID: <201404242051.DBE04650.SOMVHtQFFOLFOJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: paul@paul-moore.com, casey@schaufler-ca.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:36493 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbaDXLvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 07:51:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Casey and Paul.

At the ipsec-next tree,

  /* Audit Information */
  struct xfrm_audit {
  	u32     secid;
  	kuid_t  loginuid;
  	unsigned int sessionid;
  };

has just been killed
( https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec-next.git/commit/?id=f1370cc4a01e61007ab3020c761cef6b88ae3729 and
  https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec-next.git/commit/?id=2e71029e2c32ecd59a2e8f351517bfbbad42ac11 )
because these arguments are always calculated from current thread's security
context.

Looking at other security_secid_to_secctx() users, I noticed that
a similar struct in the netlabel code.

  /* NetLabel audit information */
  struct netlbl_audit {
  	u32 secid;
  	kuid_t loginuid;
  	unsigned int sessionid;
  };

Do you know whether we can kill "struct netlbl_audit" as well?
(In other words, is "bool" sufficient for representing "struct netlbl_audit" ?)

Regards.
