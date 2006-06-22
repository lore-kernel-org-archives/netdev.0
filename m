From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Suspending 802.11 drivers
Date: Thu, 22 Jun 2006 01:15:14 -0400
Message-ID: <43e72e890606212215y7fa64884sed718957c6ee890d@mail.gmail.com>
References: <200606152158.10079.mb@bu3sch.de>
	 <200606162036.26518.stefan@loplof.de>
	 <43e72e890606210808n187771e6k2f58789cf1fcf680@mail.gmail.com>
	 <200606212241.56208.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stefan Rompf" <stefan@loplof.de>, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:44398 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030601AbWFVFPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 01:15:16 -0400
Received: by ug-out-1314.google.com with SMTP id a2so292220ugf
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 22:15:15 -0700 (PDT)
To: "Michael Buesch" <mb@bu3sch.de>
In-Reply-To: <200606212241.56208.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/21/06, Michael Buesch <mb@bu3sch.de> wrote:
> On Wednesday 21 June 2006 17:08, Luis R. Rodriguez wrote:
> > On 6/16/06, Stefan Rompf <stefan@loplof.de> wrote:
> > > Am Donnerstag 15 Juni 2006 21:58 schrieb Michael Buesch:
> > >
> > > I think the most important question is how a suspend/resume action should be
> > > translated. For the managed case, it is clearly an association loss, normally
> > > signalled by netif_carrier_on/off() and a corresponding SIOCGIWAP event.
> > > Supplicants can act on this. In AP mode, suspend is equal to disassociating
> > > all stations. Ad-hoc... dunno.
> > >
> > > For a softmac stack like devicescape, it makes sense to have a function that
> > > abstracts these scenarios as it is the stack anyway that handles association
> > > stuff. However, I'd rather extend the existing function
> > > ieee80211_netif_oper().
> >
> > Since d80211 is already being patched for sysfs how about we use sysfs
> > (and kobjects) to maintain the state at suspend() and resume(). This
> > would allow userspace tools like supplicant running in the background
> > to pick up from sysfs where it left off and for our drivers to save
> > where we left off. ieee80211_hw can then just refer to their suspend()
> > and resume() routines from its respective struct pci_driver or struct
> > usb_device.
>
> Ok, so you mean we remove the full responsibility to recover a connection
> from the driver resume() handler and let a userspace daemon keep
> track of this?
> So basically stay with the current implementation of suspend() and
> resume() in the drivers and assume userspace does the right thing
> and detects a resume and recovers connections and so on?
> Did I understand that right? If yes, I think that's a very nice idea, too.
> Probably the best.

Michael, yes that was what I meant.
