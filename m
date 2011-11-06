From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 0/5] use kstrtoul, etc
Date: Sun,  6 Nov 2011 14:26:45 +0100
Message-ID: <1320586010-21931-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches replace calls to strict_strtoul, etc by the corresponding
calls to kstrtoul.  The complete semantic patch that makes these changes is
as follows.  This semantic patch checks that the types are as expected,
which was always the case for these files.

// <smpl>
@@
expression a,b;
{int,long} *c;
@@

-strict_strtol
+kstrtol
 (a,b,c)

@@
expression a,b;
long long *c;
@@

-strict_strtoll
+kstrtoll
 (a,b,c)

@@
typedef ulong;
expression a,b;
{ulong,unsigned long,unsigned int,size_t} *c;
@@

-strict_strtoul
+kstrtoul
 (a,b,c)

@@
expression a,b;
unsigned long long *c;
@@

-strict_strtoull
+kstrtoull
 (a,b,c)

@@
expression a,b;
u64 *c;
@@

-strict_strtoull
+kstrtou64
 (a,b,c)

@@
@@

(
+BAD(
  strict_strtoull(...)
+)
|
+BAD(
  strict_strtoul(...)
+)
|
+BAD(
  strict_strtol(...)
+)
|
+BAD(
  strict_strtoll(...)
+)
)
// </smpl>
