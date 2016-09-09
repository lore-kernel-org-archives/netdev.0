From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 1/9] selftests: move dnotify_test from Documentation/filesystems
Date: Fri,  9 Sep 2016 16:22:42 -0600
Message-ID: <86ba11fc5f22dba9b322b38eec8e63d19f6634af.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move dnotify_test from Documentation/filesystems to selftests/filesystems

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Documentation/filesystems/Makefile                 |  5 ----
 Documentation/filesystems/dnotify_test.c           | 34 ----------------------
 tools/testing/selftests/filesystems/Makefile       |  5 ++++
 tools/testing/selftests/filesystems/dnotify_test.c | 34 ++++++++++++++++++++++
 4 files changed, 39 insertions(+), 39 deletions(-)
 delete mode 100644 Documentation/filesystems/Makefile
 delete mode 100644 Documentation/filesystems/dnotify_test.c
 create mode 100644 tools/testing/selftests/filesystems/Makefile
 create mode 100644 tools/testing/selftests/filesystems/dnotify_test.c

diff --git a/Documentation/filesystems/Makefile b/Documentation/filesystems/Makefile
deleted file mode 100644
index 883010c..0000000
--- a/Documentation/filesystems/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-# List of programs to build
-hostprogs-y := dnotify_test
-
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
diff --git a/Documentation/filesystems/dnotify_test.c b/Documentation/filesystems/dnotify_test.c
deleted file mode 100644
index 8b37b4a..0000000
--- a/Documentation/filesystems/dnotify_test.c
+++ /dev/null
@@ -1,34 +0,0 @@
-#define _GNU_SOURCE	/* needed to get the defines */
-#include <fcntl.h>	/* in glibc 2.2 this has the needed
-				   values defined */
-#include <signal.h>
-#include <stdio.h>
-#include <unistd.h>
-
-static volatile int event_fd;
-
-static void handler(int sig, siginfo_t *si, void *data)
-{
-	event_fd = si->si_fd;
-}
-
-int main(void)
-{
-	struct sigaction act;
-	int fd;
-
-	act.sa_sigaction = handler;
-	sigemptyset(&act.sa_mask);
-	act.sa_flags = SA_SIGINFO;
-	sigaction(SIGRTMIN + 1, &act, NULL);
-
-	fd = open(".", O_RDONLY);
-	fcntl(fd, F_SETSIG, SIGRTMIN + 1);
-	fcntl(fd, F_NOTIFY, DN_MODIFY|DN_CREATE|DN_MULTISHOT);
-	/* we will now be notified if any of the files
-	   in "." is modified or new files are created */
-	while (1) {
-		pause();
-		printf("Got event on fd=%d\n", event_fd);
-	}
-}
diff --git a/tools/testing/selftests/filesystems/Makefile b/tools/testing/selftests/filesystems/Makefile
new file mode 100644
index 0000000..883010c
--- /dev/null
+++ b/tools/testing/selftests/filesystems/Makefile
@@ -0,0 +1,5 @@
+# List of programs to build
+hostprogs-y := dnotify_test
+
+# Tell kbuild to always build the programs
+always := $(hostprogs-y)
diff --git a/tools/testing/selftests/filesystems/dnotify_test.c b/tools/testing/selftests/filesystems/dnotify_test.c
new file mode 100644
index 0000000..8b37b4a
--- /dev/null
+++ b/tools/testing/selftests/filesystems/dnotify_test.c
@@ -0,0 +1,34 @@
+#define _GNU_SOURCE	/* needed to get the defines */
+#include <fcntl.h>	/* in glibc 2.2 this has the needed
+				   values defined */
+#include <signal.h>
+#include <stdio.h>
+#include <unistd.h>
+
+static volatile int event_fd;
+
+static void handler(int sig, siginfo_t *si, void *data)
+{
+	event_fd = si->si_fd;
+}
+
+int main(void)
+{
+	struct sigaction act;
+	int fd;
+
+	act.sa_sigaction = handler;
+	sigemptyset(&act.sa_mask);
+	act.sa_flags = SA_SIGINFO;
+	sigaction(SIGRTMIN + 1, &act, NULL);
+
+	fd = open(".", O_RDONLY);
+	fcntl(fd, F_SETSIG, SIGRTMIN + 1);
+	fcntl(fd, F_NOTIFY, DN_MODIFY|DN_CREATE|DN_MULTISHOT);
+	/* we will now be notified if any of the files
+	   in "." is modified or new files are created */
+	while (1) {
+		pause();
+		printf("Got event on fd=%d\n", event_fd);
+	}
+}
-- 
2.7.4
