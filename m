From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH v2 2/3] selinux: add the "create_queue" permission to
 the "tun_socket" class
Date: Wed, 05 Dec 2012 15:26:11 -0500
Message-ID: <20121205202611.18626.46545.stgit@localhost>
References: <20121205202144.18626.61966.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932128Ab2LEU0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 15:26:15 -0500
In-Reply-To: <20121205202144.18626.61966.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new permission to align with the new TUN multiqueue support,
"tun_socket:create_queue".

The corresponding SELinux reference policy patch is show below:

 diff --git a/policy/flask/access_vectors b/policy/flask/access_vectors
 index 28802c5..a0664a1 100644
 --- a/policy/flask/access_vectors
 +++ b/policy/flask/access_vectors
 @@ -827,6 +827,9 @@ class kernel_service

  class tun_socket
  inherits socket
 +{
 +       create_queue
 +}

  class x_pointer
  inherits x_device

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 security/selinux/include/classmap.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
index df2de54..7e9a3d1 100644
--- a/security/selinux/include/classmap.h
+++ b/security/selinux/include/classmap.h
@@ -150,6 +150,6 @@ struct security_class_mapping secclass_map[] = {
 	    NULL } },
 	{ "kernel_service", { "use_as_override", "create_files_as", NULL } },
 	{ "tun_socket",
-	  { COMMON_SOCK_PERMS, NULL } },
+	  { COMMON_SOCK_PERMS, "create_queue", NULL } },
 	{ NULL }
   };
