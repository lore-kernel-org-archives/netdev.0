From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/6] make non-modular code explicitly non-modular
Date: Mon, 28 Sep 2015 15:51:24 -0400
Message-ID: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
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
	<linux-m68k@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Build tested on net-next 34c2d9fb0498 on m68k, since that is the arch
where the three ethernet drivers changed here are available.

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
Cc: linux-m68k@lists.linux-m68k.org
Cc: netdev@vger.kernel.org

Paul Gortmaker (6):
  net/core: make sock_diag.c explicitly non-modular
  net/dcb: make dcbnl.c explicitly non-modular
  net/sched: make sch_blackhole.c explicitly non-modular
  net/ethernet: make amd/hplance.c driver explicitly non-modular
  net/ethernet: make 8390/mac8390.c driver explicitly non-modular
  net/ethernet: make apple/macmace.c driver explicitly non-modular

 drivers/net/ethernet/8390/mac8390.c  | 40 ++----------------------------------
 drivers/net/ethernet/amd/hplance.c   | 13 ++----------
 drivers/net/ethernet/apple/macmace.c | 38 +++-------------------------------
 net/core/sock_diag.c                 | 14 +++----------
 net/dcb/dcbnl.c                      | 30 +++------------------------
 net/sched/sch_blackhole.c            | 15 +++-----------
 6 files changed, 16 insertions(+), 134 deletions(-)

-- 
2.6.0.rc3
