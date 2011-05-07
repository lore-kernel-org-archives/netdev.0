From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/7] Network namespace manipulation with file descriptors
Date: Fri, 06 May 2011 19:23:29 -0700
Message-ID: <m1tyd7p7tq.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: <linux-arch@vger.kernel.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Today there are something things you can use namespaces to implement but
the userspace code is unnecessarily complex and fragile because of
limitations of the kernel interfaces.

This patchset addresses the user interface limitations by introducing
proc files you can open to get file descriptors that keep alive and
refer to your a tasks namespaces.  Those file descriptors can be passed
to the new setns system call or the NET_NS_FD argument in netlink
messages.

This patchset is sufficient to implement linux support for named network
namespaces in iproute allowing vpns to be isolated in a network
namespace where you don't have to worry about them conflicting with the
rest of your network.

This patchset is almost sufficient to remove the need for a daemon in a
container to allow you to log in.  Unfortunately a few of the namespaces
are not ready to merge yet so I have left them out.

Arch maintainers could you look over patch 7 and verify I have wired
up this new system call correctly.

These changes are also available at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-nsfd.git
