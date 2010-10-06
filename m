From: Florian Mickler <florian@mickler.org>
Subject: Re: [PATCH wireless-2.6 or stable] iwlwifi: return error when fail
 to start scanning
Date: Wed, 6 Oct 2010 19:32:45 +0200
Message-ID: <20101006193245.698957cc@schatten.dmk.lab>
References: <20101005085717.GA18012@redhat.com>
	<1286317292-10679-1-git-send-email-florian@mickler.org>
	<20101006090228.GA2523@redhat.com>
	<20101006160434.GB24581@redhat.com>
	<1286381578.12594.18.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"stable@kernel.org" <stable@kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Chatre, Reinette" <reinette.chatre@intel.com>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Cahill, Ben M" <ben.m.cahill@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286381578.12594.18.camel@wwguy-ubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Oct 2010 09:12:58 -0700
"Guy, Wey-Yi" <wey-yi.w.guy@intel.com> wrote:

> Hi Gruszka,
> 
> On Wed, 2010-10-06 at 09:04 -0700, Stanislaw Gruszka wrote:
> > This is stable friendly backport of wireless-testing commit
> > 3eecce527c7434dfd16517ce08b49632c8a26717 "iwlwifi: unify scan start
> > checks". Wireless-testing version include also a lot of cleanups.
> > 
> > On error case in {iwl3945,iwlagn}_request_scan we queue abort_scan work,
> > which in a fact do nothing, so we never complete the scan. Thats gives
> > "WARNING: at net/wireless/core.c:614 wdev_cleanup_work" and stopped
> > network connection until reload iwlwifi modules. Return of -EIO, and
> > stopping queuing any work is a fix.
> > 
> > Note there are still many cases when we can get: 
> > 
> > WARNING: at net/wireless/core.c:614 wdev_cleanup_work  
> > WARNING: at net/mac80211/scan.c:266 ieee80211_scan_completed
> > WARNING: at net/mac80211/scan.c:269 ieee80211_scan_complete
> > 
> > which are not fixed. Unfortunately does not exist single, small fix
> > for that problems, and we probably will see some more bug reports
> > with scan warnings. As solution we rewrite iwl-scan.c code to avoid
> > all possible race conditions. That quite big patch set is queued
> > for 2.6.37 .
> > 
> > Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> > ---
> > Patch is intended for wireless-2.6, or in case when it does not
> > make 2.6.36 release, for -stable 2.6.36.y 
> > 
> 
> Is this the replacement for Mickler's patch?
> 
> Thanks
> Wey
> 

This is on top of current mainline, as far as I see. (And it replaces
the patch I sent few hours ago)

Regards,
Flo
