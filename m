From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] sb1000: reduce ioctl stack usage
Date: Sun, 30 Jan 2005 18:12:00 -0800
Message-ID: <41FD93F0.2040601@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030703040901060907040202"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>, netdev <netdev@oss.sgi.com>,
        fventuri@mediaone.net, shirsch@adelphia.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030703040901060907040202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


sb1000_dev_ioctl() (on i386) uses 824 bytes of stack space,
all due to overuse of inline functions.
By changing a few infrequently used functions to non-inline,
the stack usage is reduced to only 60 bytes.
Nothing in a fast path is changed.

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  drivers/net/sb1000.c |   20 ++++++++++----------
  1 files changed, 10 insertions(+), 10 deletions(-)

--------------030703040901060907040202
Content-Type: text/x-patch;
 name="sb1000_stack.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sb1000_stack.patch"


diff -Naurp ./drivers/net/sb1000.c~sb1000_stack ./drivers/net/sb1000.c
--- ./drivers/net/sb1000.c~sb1000_stack	2004-12-24 13:33:51.000000000 -0800
+++ ./drivers/net/sb1000.c	2005-01-30 17:49:27.409413904 -0800
@@ -116,15 +116,15 @@ static inline int sb1000_start_get_set_c
 static inline int sb1000_end_get_set_command(const int ioaddr[],
 	const char* name);
 static inline int sb1000_activate(const int ioaddr[], const char* name);
-static inline int sb1000_get_firmware_version(const int ioaddr[],
+static int sb1000_get_firmware_version(const int ioaddr[],
 	const char* name, unsigned char version[], int do_end);
-static inline int sb1000_get_frequency(const int ioaddr[], const char* name,
+static int sb1000_get_frequency(const int ioaddr[], const char* name,
 	int* frequency);
-static inline int sb1000_set_frequency(const int ioaddr[], const char* name,
+static int sb1000_set_frequency(const int ioaddr[], const char* name,
 	int frequency);
-static inline int sb1000_get_PIDs(const int ioaddr[], const char* name,
+static int sb1000_get_PIDs(const int ioaddr[], const char* name,
 	short PID[]);
-static inline int sb1000_set_PIDs(const int ioaddr[], const char* name,
+static int sb1000_set_PIDs(const int ioaddr[], const char* name,
 	const short PID[]);
 
 /* SB1000 commands for frame rx interrupt */
@@ -552,7 +552,7 @@ sb1000_activate(const int ioaddr[], cons
 }
 
 /* get SB1000 firmware version */
-static inline int
+static int
 sb1000_get_firmware_version(const int ioaddr[], const char* name,
 	unsigned char version[], int do_end)
 {
@@ -575,7 +575,7 @@ sb1000_get_firmware_version(const int io
 }
 
 /* get SB1000 frequency */
-static inline int
+static int
 sb1000_get_frequency(const int ioaddr[], const char* name, int* frequency)
 {
 	unsigned char st[7];
@@ -592,7 +592,7 @@ sb1000_get_frequency(const int ioaddr[],
 }
 
 /* set SB1000 frequency */
-static inline int
+static int
 sb1000_set_frequency(const int ioaddr[], const char* name, int frequency)
 {
 	unsigned char st[7];
@@ -622,7 +622,7 @@ sb1000_set_frequency(const int ioaddr[],
 }
 
 /* get SB1000 PIDs */
-static inline int
+static int
 sb1000_get_PIDs(const int ioaddr[], const char* name, short PID[])
 {
 	unsigned char st[7];
@@ -656,7 +656,7 @@ sb1000_get_PIDs(const int ioaddr[], cons
 }
 
 /* set SB1000 PIDs */
-static inline int
+static int
 sb1000_set_PIDs(const int ioaddr[], const char* name, const short PID[])
 {
 	unsigned char st[7];

--------------030703040901060907040202--
