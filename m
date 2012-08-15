From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [RFC PATCH 0/5] net: socket bind to file descriptor introduced
Date: Wed, 15 Aug 2012 20:21:56 +0400
Message-ID: <20120815161141.7598.16682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: thierry.reding@avionic-design.de, bfields@redhat.com,
	eric.dumazet@gmail.com, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, x86@kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	akpm@linux-foundation.org, tim.c.chen@linux.intel.com,
	devel@openvz.org, ebiederm@xmission.com
To: tglx@linutronix.de, mingo@redhat.com, davem@davemloft.net,
	hpa@zytor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set introduces new socket operation and new system call:
sys_fbind(), which allows to bind socket to opened file.
File to bind to can be created by sys_mknod(S_IFSOCK) and opened by
open(O_PATH).

This system call is especially required for UNIX sockets, which has name
lenght limitation.

The following series implements...

---

Stanislav Kinsbursky (5):
      net: cleanup unix_bind() a little
      net: split unix_bind()
      net: new protocol operation fbind() introduced
      net: fbind() for unix sockets protocol operations introduced
      syscall: sys_fbind() introduced


 arch/x86/syscalls/syscall_32.tbl |    1 
 arch/x86/syscalls/syscall_64.tbl |    1 
 include/linux/net.h              |    2 +
 include/linux/syscalls.h         |    1 
 kernel/sys_ni.c                  |    3 +
 net/socket.c                     |   25 +++++++
 net/unix/af_unix.c               |  136 ++++++++++++++++++++++++++++++--------
 7 files changed, 140 insertions(+), 29 deletions(-)
