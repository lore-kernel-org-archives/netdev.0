From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the suspend tree
Date: Fri, 21 May 2010 10:29:13 +1000
Message-ID: <20100521102913.ae4e8cd2.sfr@canb.auug.org.au>
References: <20100507130821.3fb72c9d.sfr@canb.auug.org.au>
	<201005080413.24465.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Helmut Schaa <Helmut.Schaa@gmx.de>,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Linus <torvalds@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <201005080413.24465.rjw@sisk.pl>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John, Dave,

On Sat, 8 May 2010 04:13:24 +0200 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
>
> On Friday 07 May 2010, Stephen Rothwell wrote:
> > 
> > After merging the suspend tree, today's linux-next build (x86_64
> > allmodconfig) failed like this:
> > 
> > net/mac80211/scan.c: In function 'ieee80211_scan_state_decision':
> > net/mac80211/scan.c:510: error: implicit declaration of function 'pm_qos_requirement'
> > 
> > Caused by commit 62bad14fc6e0911a99882c261390968977d43283 ("PM QOS
> > update") from the suspend tree interacting with commit
> > df13cce53a7b28a81460e6bfc4857e9df4956141 ("mac80211: Improve software
> > scan timing") from the net tree.
> > 
> > I have added the following merge fixup patch and can carry it as
> > necessary:
> 
> Thanks a lot, please do so if that's not a problem.
> 
> Both trees are based on Linus' current and I don't see a good way of fixing
> this issue in any of them individually.

The suspend tree has been merged into Linus' tree, so this patch is
needed in the net tree before it is merged (or as part of the merge).

Here is the patch again:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 7 May 2010 13:02:54 +1000
Subject: [PATCH] wireless: update for pm_qos_requirement to pm_qos_request rename

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/mac80211/scan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index e14c441..e1b0be7 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -510,7 +510,7 @@ static int ieee80211_scan_state_decision(struct ieee80211_local *local,
 		bad_latency = time_after(jiffies +
 				ieee80211_scan_get_channel_time(next_chan),
 				local->leave_oper_channel_time +
-				usecs_to_jiffies(pm_qos_requirement(PM_QOS_NETWORK_LATENCY)));
+				usecs_to_jiffies(pm_qos_request(PM_QOS_NETWORK_LATENCY)));
 
 		listen_int_exceeded = time_after(jiffies +
 				ieee80211_scan_get_channel_time(next_chan),
-- 
1.7.1

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
