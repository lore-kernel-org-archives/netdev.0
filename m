From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 0/14] user namespaces v2: continue targetting capabilities
Date: Tue, 26 Jul 2011 18:58:23 +0000
Message-ID: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Cc: dhowells@redhat.com, ebiederm@xmission.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

here is a set of patches to continue targetting capabilities
where appropriate.  This set goes about as far as is possible
without making the VFS user namespace aware, meaning that the
VFS can provide a namespaced view of userids, i.e init_user_ns
sees file owner 500, while child user ns sees file owner 0 or
1000.  (There are a few other things, like siginfos, which can
be addressed before we address the VFS).

With this set applied, you can create and configure veth netdevs
if your user namespace owns your network namespace (and you are
privileged), but not otherwise.

Some simple testcases can be found at
https://code.launchpad.net/~serge-hallyn/+junk/usernstests with
packages at https://launchpad.net/~serge-hallyn/+archive/userns-natty

Feedback very much appreciated.

Changes since v1:
    documentation: incorporate feedback on user_namespaces.txt
    netlink_capable: use sock_net() instead of ifdefs
