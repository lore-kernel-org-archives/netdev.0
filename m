From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch v8 0/3] net: reserve ports for applications using fixed port numbers
Date: Mon, 12 Apr 2010 06:03:54 -0400
Message-ID: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>
Cc: Octavian Purdila <opurdila@ixiacom.com>, ebiederm@xmission.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Amerigo Wang <amwang@redhat.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes from the previous version:
- Rename proc_{get,put}_ulong to proc_{get,put}_long();
- Fix potential dead loop problems in cma code.

------------->

This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
allows users to reserve ports for third-party applications.

The reserved ports will not be used by automatic port assignments
(e.g. when calling connect() or bind() with port number 0). Explicit
port allocation behavior is unchanged.

There are still some miss behaviors with regard to proc parsing in odd
invalid cases (for "40000\0-40001" all is acknowledged but only 40000
is accepted) but they are not easy to fix without changing the current
"acknowledge how much we accepted" behavior.

Because of that and because the same issues are present in the
existing proc_dointvec code as well I don't think its worth holding
the actual feature (port reservation) after such petty error recovery
issues.
