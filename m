From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH] x86: Wire up 32-bit direct socket calls
Date: Tue, 14 Jul 2015 15:24:24 -0700
Message-ID: <cb5138299d37d5800e2d135b01a7667fa6115854.1436912629.git.luto@kernel.org>
Cc: Tulio Magno Quites Machado Filho <tuliom@linux.vnet.ibm.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexander Larsson <alexl@redhat.com>,
	Cosimo Cecchi <cosimo@endlessm.com>,
	Dan Nicholson <nicholson@endlessm.com>,
	libc-alpha <libc-alpha@sourceware.org>,
	Rajalakshmi Srinivasaraghavan <raji@linux.vnet.ibm.com>,
	Andy Lutomirski <luto@kernel.org>
To: X86 ML <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>
Return-path: <libc-alpha-return-60952-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On x86_64, there's no socketcall syscall; instead all of the socket
calls are real syscalls.  For 32-bit programs, we're stuck offering
the socketcall syscall, but it would be nice to expose the direct
calls as well.  This will enable seccomp to filter socket calls (for
new userspace only, but that's fine for some applications) and it
will provide a tiny performance boost.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/syscalls/syscall_32.tbl | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index ef8187f9d28d..25e3cf1cd8fd 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -365,3 +365,18 @@
 356	i386	memfd_create		sys_memfd_create
 357	i386	bpf			sys_bpf
 358	i386	execveat		sys_execveat			stub32_execveat
+359	i386	socket			sys_socket
+360	i386	socketpair		sys_socketpair
+361	i386	bind			sys_bind
+362	i386	connect			sys_connect
+363	i386	listen			sys_listen
+364	i386	accept4			sys_accept4
+365	i386	getsockopt		sys_getsockopt			compat_sys_getsockopt
+366	i386	setsockopt		sys_setsockopt			compat_sys_setsockopt
+367	i386	getsockname		sys_getsockname
+368	i386	getpeername		sys_getpeername
+369	i386	sendto			sys_sendto
+370	i386	sendmsg			sys_sendmsg			compat_sys_sendmsg
+371	i386	recvfrom		sys_recvfrom			compat_sys_recvfrom
+372	i386	recvmsg			sys_recvmsg			compat_sys_recvmsg
+373	i386	shutdown		sys_shutdown
-- 
2.4.3
