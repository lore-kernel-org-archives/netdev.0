From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: mmotm 2010-05-11 - dies in pm_qos_update_request()
Date: Thu, 13 May 2010 00:33:25 +0200
Message-ID: <201005130033.25723.rjw@sisk.pl>
References: <201005120149.o4C1n7P4002637@imap1.linux-foundation.org> <201005122307.20860.rjw@sisk.pl> <17286.1273702370@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17286.1273702370@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 13 May 2010, Valdis.Kletnieks@vt.edu wrote:
> On Wed, 12 May 2010 23:07:20 +0200, "Rafael J. Wysocki" said:
>  
> > > I suspect this commit:
> > > 
> > > commit 23606cf5d1192c2b17912cb2ef6e62f9b11de133
> > > Author: Rafael J. Wysocki <rjw@sisk.pl>
> > > Date:   Sun Mar 14 14:35:17 2010 +0000
> > > 
> > >     e1000e / PCI / PM: Add basic runtime PM support (rev. 4)
> > 
> > No, I don't think so.  I'm running -rc6 with this patch applied on a box with
> > e1000e and it works just fine.
> > 
> > Please try to revert this one instead:
> > 
> > http://git.kernel.org/?p=linux/kernel/git/rafael/suspend-2.6.git;a=patch;h=ed77134bfccf5e75b6cbadab268e559dbe6a4ebb
> 
> Isn't a clean revert - build dies with:
> 
>   CC      net/mac80211/scan.o
> net/mac80211/scan.c: In function 'ieee80211_scan_state_decision':
> net/mac80211/scan.c:510: error: implicit declaration of function 'pm_qos_request'
> make[1]: *** [net/mac80211/scan.o] Error 1
> make: *** [net/mac80211/scan.o] Error 2
> 
> Will investigate more later, find what other commit needs reverting.

Simply rename pm_qos_request() to pm_qos_requirement() in
ieee80211_scan_state_decision() and it should build.

Rafael
