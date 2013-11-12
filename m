From: Andreas Henriksson <andreas@fatal.se>
Subject: Bug#511720: [PATCH iproute2] ss: avoid passing negative numbers to malloc
Date: Tue, 12 Nov 2013 19:52:14 +0100
Message-ID: <20131112185214.GA29913@amd64.fatal.se>
Reply-To: Andreas Henriksson <andreas@fatal.se>, 511720@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.511720.B511720.13842827986693@bugs.debian.org>
Content-Disposition: inline
List-URL: <http://lists.debian.org/debian-bugs-dist/>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Example:

$ ss state established \( sport = :4060  or sport = :4061 or sport = :4062  or sport = :4063 or sport = :4064  or sport = :4065 or sport = :4066  or sport = :4067 \)  > /dev/null
Aborted

In the example above ssfilter_bytecompile(...) will return (int)136.
char l1 = 136; means -120 which will result in a negative number
being passed to malloc at misc/ss.c:913.

Simply declare l1 and l2 as intergers to avoid the char overflow.

This is one of the issues originally reported in http://bugs.debian.org/511720

Reported-by: Andreas Schuldei <andreas@debian.org>
Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 misc/ss.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index c0369f1..db3a3a4 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -907,7 +907,8 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 	}
 		case SSF_OR:
 	{
-		char *a1, *a2, *a, l1, l2;
+		char *a1, *a2, *a;
+		int l1, l2;
 		l1 = ssfilter_bytecompile(f->pred, &a1);
 		l2 = ssfilter_bytecompile(f->post, &a2);
 		if (!(a = malloc(l1+l2+4))) abort();
-- 
1.8.4.3
