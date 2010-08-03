From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Tue, 3 Aug 2010 20:04:37 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008032001430.1519@obet.zrqbmnf.qr>
References: <4C5832F9.50004@trash.net> <x6bp9jy7sj@gzp> <4C584C63.8010607@trash.net> <x6vd7rwrah@gzp> <x6lj8nwqu4@gzp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: "Gabor Z. Papp" <gzp@papp.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <x6lj8nwqu4@gzp>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 2010-08-03 19:25, Gabor Z. Papp wrote:

>* "Gabor Z. Papp" <gzp@papp.hu>:
>
>| Note the difference, new undefined reference: `libxt_IDLETIMER_init
>
>--disable-shared --enable-static configure options cause the problems.
>
>--enable-shared --disable-static compiles fine, but I would like to
>link against the static libs.

(BTW, with --disable-shared you remove the possibility to use any .so
files whatsoever. You can use --enable-static --enable-shared to get
both "all in one binary" and ".so support".)



The following changes since commit 371cea299f0b2eb100b9fc9fb99089640d2d606f:

  xtables: remove unnecessary cast (2010-08-03 19:56:11 +0200)

are available in the git repository at:
  git://dev.medozas.de/iptables master

Jan Engelhardt (1):
      build: fix static linking

 extensions/libxt_IDLETIMER.c |    2 +-
 extensions/libxt_TEE.c       |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
[Actually there's also the "remove unnecessary cast" patch that is not 
included in this listing, but merging that should be ok.]



parent 371cea299f0b2eb100b9fc9fb99089640d2d606f (v1.4.9-18-g371cea2)
commit 0428e5a6541c3f5eaaf683d8da9ea60c44eac4c7
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Aug 3 19:58:38 2010 +0200

build: fix static linking

Gabor Z. Papp noted this link-time error when configuring with
--enable-static:

extensions/libext4.a(initext4.o): In function "init_extensions":
extensions/initext4.c:144: undefined reference to "libxt_IDLETIMER_init"
extensions/initext4.c:145: undefined reference to "libxt_TEE_init"

Indeed, since the two modules did not use our special macro "_init"
(which expands to libxt_foo_init), initext4.c could not find them by
that name. Correct this.

References: http://marc.info/?l=netfilter&m=128085480927924&w=2
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 extensions/libxt_IDLETIMER.c |    2 +-
 extensions/libxt_TEE.c       |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/extensions/libxt_IDLETIMER.c b/extensions/libxt_IDLETIMER.c
index 12573a4..1562e02 100644
--- a/extensions/libxt_IDLETIMER.c
+++ b/extensions/libxt_IDLETIMER.c
@@ -132,7 +132,7 @@ static struct xtables_target idletimer_tg_reg = {
 	.extra_opts    = idletimer_tg_opts,
 };
 
-static __attribute__((constructor)) void idletimer_tg_ldr(void)
+void _init(void)
 {
 	xtables_register_target(&idletimer_tg_reg);
 }
diff --git a/extensions/libxt_TEE.c b/extensions/libxt_TEE.c
index f8e7fd1..e4c0607 100644
--- a/extensions/libxt_TEE.c
+++ b/extensions/libxt_TEE.c
@@ -195,7 +195,7 @@ static struct xtables_target tee_tg6_reg = {
 	.extra_opts    = tee_tg_opts,
 };
 
-static __attribute__((constructor)) void tee_tg_ldr(void)
+void _init(void)
 {
 	xtables_register_target(&tee_tg_reg);
 	xtables_register_target(&tee_tg6_reg);
-- 
# Created with git-export-patch
