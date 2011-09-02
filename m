From: Serge Hallyn <serge@hallyn.com>
Subject: user namespaces v3: continue targetting capabilities
Date: Fri,  2 Sep 2011 19:56:23 +0000
Message-ID: <1314993400-6910-1-git-send-email-serge@hallyn.com>
To: akpm@osdl.org, segooon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	dhowells@redhat.com, ebiederm@xmission.com, rdunlap@xenotime.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was last sent Jul 26, and incorporates feedback from that thread.
The last patch, 0015-make-kernel-signal.c-user-ns-safe-v2.patch, is new,
so could stand extra scrutiny.

This patchset is a basis for Eric's set which allows assigning a
filesystem to a user namespace
(http://git.kernel.org/?p=linux/kernel/git/ebiederm/linux-userns-devel.git),
which is the last hurdle to starting to employ user namespaces to help
constrain root in a container.  So if there is no more major feedback,
I'd love to see this get a spin in -mm so we can proceed with that.

[ v2 intro message: ]

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
packages at
https://launchpad.net/~serge-hallyn/+archive/userns-natty

Feedback very much appreciated.
