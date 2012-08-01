From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: assert_cfg80211_lock warning with Linux v3.5-8833-g2d53492
Date: Wed, 01 Aug 2012 19:14:45 +0200
Message-ID: <1343841285.4638.10.camel@jlt3.sipsolutions.net>
References: <20120801131232.GA1785@zod.bos.redhat.com>
	 <20120801141810.GB27433@tuxdriver.com> <50194D7A.6060400@broadcom.com>
	 <5019506C.6020707@broadcom.com>
	 <1343836438.4638.5.camel@jlt3.sipsolutions.net>
	 <20120801161959.GC22963@thinkpad-t410>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Josh Boyer <jwboyer@redhat.com>,
	Brett Rudley <brudley@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Seth Forshee <seth.forshee@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:44218 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255Ab2HAROz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 13:14:55 -0400
In-Reply-To: <20120801161959.GC22963@thinkpad-t410>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-01 at 11:19 -0500, Seth Forshee wrote:
> On Wed, Aug 01, 2012 at 05:53:58PM +0200, Johannes Berg wrote:
> > On Wed, 2012-08-01 at 17:51 +0200, Arend van Spriel wrote:
> > > On 08/01/2012 05:38 PM, Arend van Spriel wrote:
> > > >> brcmsmac needs to hold cfg80211_mutex before calling freq_reg_info...
> > > >> > 
> > > >> > It looks like those calls were added in mid-June.
> > > >> > 
> > > > I think mid-june sounds about right. We never observed the warning when
> > > > changes to use regulatory infrastructure were tested/reviewed. Should
> > > > this precondition be mentioned in cfg80211.h?
> > > > 
> > > > Gr. AvS
> > > 
> > > Diving in further it seems brcmsmac can not grab the cfg80211_mutex. So
> > > another solution is needed.
> > 
> > Yeah I was going to say -- how can it possibly access that? It seems
> > that in some patch the API got broken, it should be taking the lock or
> > whatever ... I'll leave it to Luis to sort out though :-P
> 
> In other drivers freq_reg_info only seems to get used by the regulatory
> notifiers, which get called with the lock held. brcmsmac is wanting to
> know whether or not OFDM is allowed when setting the channel though, and
> I didn't find that information anywhere outside the regulatory
> information. If there's another way then calling freq_reg_info() could
> be avoided. Or maybe we could add an OFDM flag to the channel
> information?

Seems reasonable to add the flags (or some of them) to the channel
flags, yeah.

johannes
