From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] ptp: make ptp_clock_info const
Date: Mon, 21 Aug 2017 23:01:12 +0530
Message-ID: <1503336672-22918-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, richardcochran@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are only used in a copy operation.
Done using Coccinelle.

@match disable optional_qualifier@
identifier s;
@@
static struct ptp_clock_info s = {...};

@ref@
position p;
identifier match.s;
@@
s@p

@good1@
position ref.p;
identifier match.s,f,c;
expression e;
@@
(
e = s@p
|
e = s@p.f
|
c(...,s@p.f,...)
|
c(...,s@p,...)
)

@bad depends on  !good1@
position ref.p;
identifier match.s;
@@
s@p

@depends on forall !bad disable optional_qualifier@
identifier match.s;
@@
static
+ const
struct ptp_clock_info s;

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
File ptp_ixp46x.c is not tested as I could not find any architecture
to cross compile it. 

 drivers/ptp/ptp_dte.c    | 2 +-
 drivers/ptp/ptp_ixp46x.c | 2 +-
 drivers/ptp/ptp_kvm.c    | 2 +-
 drivers/ptp/ptp_pch.c    | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/ptp/ptp_dte.c b/drivers/ptp/ptp_dte.c
index faf6f7a..6edd3b9 100644
--- a/drivers/ptp/ptp_dte.c
+++ b/drivers/ptp/ptp_dte.c
@@ -221,7 +221,7 @@ static int ptp_dte_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info ptp_dte_caps = {
+static const struct ptp_clock_info ptp_dte_caps = {
 	.owner		= THIS_MODULE,
 	.name		= "DTE PTP timer",
 	.max_adj	= 50000000,
diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index 344a3ba..1171ffd 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -236,7 +236,7 @@ static int ptp_ixp_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info ptp_ixp_caps = {
+static const struct ptp_clock_info ptp_ixp_caps = {
 	.owner		= THIS_MODULE,
 	.name		= "IXP46X timer",
 	.max_adj	= 66666655,
diff --git a/drivers/ptp/ptp_kvm.c b/drivers/ptp/ptp_kvm.c
index bb86569..2b1b212 100644
--- a/drivers/ptp/ptp_kvm.c
+++ b/drivers/ptp/ptp_kvm.c
@@ -150,7 +150,7 @@ static int ptp_kvm_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info ptp_kvm_caps = {
+static const struct ptp_clock_info ptp_kvm_caps = {
 	.owner		= THIS_MODULE,
 	.name		= "KVM virtual PTP",
 	.max_adj	= 0,
diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 3aa22ae..b328517 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -509,7 +509,7 @@ static int ptp_pch_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info ptp_pch_caps = {
+static const struct ptp_clock_info ptp_pch_caps = {
 	.owner		= THIS_MODULE,
 	.name		= "PCH timer",
 	.max_adj	= 50000000,
-- 
1.9.1
