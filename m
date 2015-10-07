From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH-next v2 0/4] make non-modular code explicitly non-modular
Date: Wed, 7 Oct 2015 17:27:42 -0400
Message-ID: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Anish Bhatt <anish@chelsio.com>,
	Craig Gallek <kraig@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Varka Bhadram <varkabhadram@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52893 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840AbbJGVae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 17:30:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[v2: drop m68k patches that Geert converted to modules; add one ARM
 driver patch ; update net-next baseline to today; switch to ARM
 for build testing.]

In a previous merge window, we made changes to allow better
delineation between modular and non-modular code in commit
0fd972a7d91d6e15393c449492a04d94c0b89351 ("module: relocate module_init
from init.h to module.h").  This allows us to now ensure module code
looks modular and non-modular code does not accidentally look modular
just to avoid suffering build breakage.

Here we target code that is, by nature of their Makefile and/or
Kconfig settings, only available to be built-in, but implicitly
presenting itself as being possibly modular by way of using modular
headers, macros, and functions.

The goal here is to remove that illusion of modularity from these
files, but in a way that leaves the actual runtime unchanged.
In doing so, we remove code that has never been tested and adds
no value to the tree.  And we continue the process of expecting a
level of consistency between the Kconfig/Makefile of code and the
code in use itself.

Fortuntately the net subsystem has relatively few instances, given
the overall amount of code and drivers it contains.  For comparison
there are over 300 instances tree wide, resulting in a possible net
removal of on the order of 5000 lines of unused code.

Build tested on net-next from today, on ARM, since that is the arch
where the one ethernet driver changed here is available.

Paul.
--

Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Anish Bhatt <anish@chelsio.com>
Cc: Craig Gallek <kraig@google.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Shani Michaeli <shanim@mellanox.com>
Cc: Varka Bhadram <varkabhadram@gmail.com>
Cc: netdev@vger.kernel.org

Paul Gortmaker (4):
  net/core: make sock_diag.c explicitly non-modular
  net/dcb: make dcbnl.c explicitly non-modular
  net/sched: make sch_blackhole.c explicitly non-modular
  drivers/net/ethernet: make ti/cpsw-phy-sel.c explicitly non-modular

 drivers/net/ethernet/ti/cpsw-phy-sel.c | 10 ++++------
 net/core/sock_diag.c                   | 14 +++-----------
 net/dcb/dcbnl.c                        | 30 +++---------------------------
 net/sched/sch_blackhole.c              | 15 +++------------
 4 files changed, 13 insertions(+), 56 deletions(-)

-- 
2.6.0.rc3
