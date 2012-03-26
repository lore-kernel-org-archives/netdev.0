From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Mon, 26 Mar 2012 17:27:30 +0200
Message-ID: <20120326152730.GA10212@localhost.localdomain>
References: <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321170003.GA5533@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
 <20120322064107.GB2182@netboy.at.omicron.at>
 <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
 <20120324065147.GB2201@netboy.at.omicron.at>
 <CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60839 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617Ab2CZP1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 11:27:42 -0400
Received: by wibhj6 with SMTP id hj6so4455193wib.1
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 08:27:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 11:07:40AM -0400, chetan loke wrote:
> On Sat, Mar 24, 2012 at 2:51 AM, Richard Cochran
> <richardcochran@gmail.com> wrote:
> > On Fri, Mar 23, 2012 at 03:39:08PM -0400, chetan loke wrote:
> >>
> >> So, how is it working today? Because we could have tx and rx
> >> completions on different CPUs. Is it not possible to have the
> >> following race today - between timecompare_update->timecompare_offset
> >> -> timecounter_readdelta of say Rx and timecounter_cyc2time from Tx?
> >
> > I works (in the igb) because of the spinlock. You know, that thing
> > that you are so against using.
> >
> 
> I meant, was there a lock before the PHC functionality in igb?

There was no lock, and yes, it was a bug.

> >> How about rate limiting at the PHC class driver level? And then it
> >> will work across the board for all the adapters at the device level.
> >
> > No, don't go there. Enough bikeshedding already. If you have a serious
> 
> can a user without root privileges use get/adj/set time ioctls for the
> PHC functionality?

Depends on how you set the character device node permissions.

Thanks,
Richard
