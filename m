From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/4] sysctl: Remember the ctl_table we passed to register_sysctl_paths
Date: Thu, 29 Nov 2007 10:46:26 -0700
Message-ID: <m1fxypc5cd.fsf_-_@ebiederm.dsl.xmission.com>
References: <4742C73C.3010904@openvz.org>
	<m1odddc5mf.fsf@ebiederm.dsl.xmission.com>
	<m1k5o1c5eh.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Pavel Emelyanov <xemul@openvz.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Olaf Kirch <okir@suse.de>, Olaf Hering <olaf@aepfle.de>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48090 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761318AbXK2RyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 12:54:06 -0500
In-Reply-To: <m1k5o1c5eh.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Thu, 29 Nov 2007 10:45:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


By doing this we allow users of register_sysctl_paths that build
and dynamically allocate their ctl_table to be simpler.  This allows
them to just remember the ctl_table_header returned from
register_sysctl_paths from which they can now find the
ctl_table array they need to free.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sysctl.h |    1 +
 kernel/sysctl.c        |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index eb522bf..8b2e9e0 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1063,6 +1063,7 @@ struct ctl_table_header
 	struct list_head ctl_entry;
 	int used;
 	struct completion *unregistering;
+	struct ctl_table *ctl_table_arg;
 };
 
 /* struct ctl_path describes where in the hierarchy a table is added */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index fa92e70..effae87 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1598,6 +1598,7 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 		new += 2;
 	}
 	*prevp = table;
+	header->ctl_table_arg = table;
 
 	INIT_LIST_HEAD(&header->ctl_entry);
 	header->used = 0;
-- 
1.5.3.rc6.17.g1911

