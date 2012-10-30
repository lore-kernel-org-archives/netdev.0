From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH] net: dsa/slave: Fix compilation warnings
Date: Tue, 30 Oct 2012 13:01:01 +0530
Message-ID: <CAKohponOKk5e2Sxyhjw-XvzVxF3tNp66rsnYCwvwHazAPAauKw@mail.gmail.com>
References: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org>
	<1351540778.2721.7.camel@bwh-desktop.uk.solarflarecom.com>
	<CAKohponL_3m2KVytiWm8ZHyB5aimk8CzGrqr5J0LMy8MFGodHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, linaro-dev@lists.linaro.org,
	patches@linaro.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKohponL_3m2KVytiWm8ZHyB5aimk8CzGrqr5J0LMy8MFGodHg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 October 2012 12:15, Viresh Kumar <viresh.kumar@linaro.org> wrote:
> And so, if we select NET_DSA from these tagging drivers, then only slave.c will
> get compiled. Otherwise slave.c dsa.c dsa_core.c wouldn't be compiled and so
> no warnings.

If my above explanation/assumption is correct, then please review following
patch:

--------------------------x-----------------------x----------------

From: Viresh Kumar <viresh.kumar@linaro.org>
Date: Mon, 29 Oct 2012 22:19:14 +0530
Subject: [PATCH] net: dsa/slave: Fix compilation warnings

Currently when none of CONFIG_NET_DSA_TAG_DSA, CONFIG_NET_DSA_TAG_EDSA and
CONFIG_NET_DSA_TAG_TRAILER is defined, we get following compilation warnings:

net/dsa/slave.c:51:12: warning: 'dsa_slave_init' defined but not used
[-Wunused-function]
net/dsa/slave.c:60:12: warning: 'dsa_slave_open' defined but not used
[-Wunused-function]
net/dsa/slave.c:98:12: warning: 'dsa_slave_close' defined but not used
[-Wunused-function]
net/dsa/slave.c:116:13: warning: 'dsa_slave_change_rx_flags' defined
but not used [-Wunused-function]
net/dsa/slave.c:127:13: warning: 'dsa_slave_set_rx_mode' defined but
not used [-Wunused-function]
net/dsa/slave.c:136:12: warning: 'dsa_slave_set_mac_address' defined
but not used [-Wunused-function]
net/dsa/slave.c:164:12: warning: 'dsa_slave_ioctl' defined but not
used [-Wunused-function]

Earlier approach to fix this was discussed here:

lkml.org/lkml/2012/10/29/549

This is another approach to fix it. This is done by some changes in config
options, which make more sense than the earlier approach. As, atleast one
tagging option must always be selected for using net/dsa/ infrastructure, this
patch selects NET_DSA from tagging configs instead of having it as an selectable
config.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 drivers/net/dsa/Kconfig |  1 -
 net/dsa/Kconfig         | 16 +++++++++-------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index dd151d5..96eae22 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -1,5 +1,4 @@
 menu "Distributed Switch Architecture drivers"
-	depends on NET_DSA

 config NET_DSA_MV88E6XXX
 	tristate
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 274791c..f7c6cef 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,5 +1,5 @@
 config NET_DSA
-	tristate "Distributed Switch Architecture support"
+	tristate
 	default n
 	depends on EXPERIMENTAL && NETDEVICES && !S390
 	select PHYLIB
@@ -8,19 +8,21 @@ config NET_DSA
 	  the Distributed Switch Architecture.


-if NET_DSA
+menu "Distributed Switch Architecture support"

 # tagging formats
 config NET_DSA_TAG_DSA
-	bool
+	bool "Original DSA packet tagging format"
+	select NET_DSt
 	default n

 config NET_DSA_TAG_EDSA
-	bool
+	bool "Ethertype DSA packet tagging format"
+	select NET_DSA
 	default n

 config NET_DSA_TAG_TRAILER
-	bool
+	bool "Trailer DSA packet tagging format"
+	select NET_DSA
 	default n
-
-endif
+endmenu
