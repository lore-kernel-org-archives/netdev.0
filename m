From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: net/kbuild trees build failure
Date: Wed, 9 Dec 2009 10:11:26 +1100
Message-ID: <20091209101126.35bf0fd3.sfr@canb.auug.org.au>
References: <20091207200317.57820f0a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Sam Ravnborg <sam@ravnborg.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Michal Marek <mmarek@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091207200317.57820f0a.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michal,

On Mon, 7 Dec 2009 20:03:17 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Today's linux-next build (powerpc allyesconfig) failed like this:
> 
> In file included from drivers/net/wireless/iwlwifi/iwl3945-base.c:57:
> drivers/net/wireless/iwlwifi/iwl-core.h:66:30: error: linux/utsrelease.h: No such file or directory
> 
> Caused by commit 250cce26d5d03337aec4ff8405121f026adb4a89 ("iwlwifi:
> driver version track kernel version") from the net tree interacting with
> commit 8e5c76aace9705b6983cfbf5eb2f2e869dab6738 ("kbuild: move
> utsrelease.h to include/generated") from the kbuild tree.
> 
> I applied this patch for today (and will carry it as necessary):

With the merge of the net tree into Linus' tree today, this patch (or
something else) is needed in the kbuild tree to avoid the above build
failure.  I have reproduced the patch below in case you want to use it.
I will be applying it as a merge fix to the merge of the kbuild tree
today.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 7 Dec 2009 19:56:42 +1100
Subject: [PATCH] net: fix for utsrelease.h moving to generated

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/wireless/iwlwifi/iwl-core.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 675b7df..27ca859 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -63,7 +63,7 @@
 #ifndef __iwl_core_h__
 #define __iwl_core_h__
 
-#include <linux/utsrelease.h>
+#include <generated/utsrelease.h>
 
 /************************
  * forward declarations *
-- 
1.6.5.3


-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
