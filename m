From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.23-rc1 sky2 boot crash in sky2_mac_intr
Date: Wed, 25 Jul 2007 01:30:31 +0200
Message-ID: <6bffcb0e0707241630p3599ad99sfd778097b307e78c@mail.gmail.com>
References: <20070724082205.GA19480@paradigm.rfc822.org>
	 <20070724095008.0eb154fe@oldman.hamilton.local>
	 <20070724094042.GA6414@paradigm.rfc822.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Florian Lohoff" <flo@rfc822.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:27060 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870AbXGXXac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 19:30:32 -0400
Received: by wa-out-1112.google.com with SMTP id v27so12140wah
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 16:30:31 -0700 (PDT)
In-Reply-To: <20070724094042.GA6414@paradigm.rfc822.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On 24/07/07, Florian Lohoff <flo@rfc822.org> wrote:
> On Tue, Jul 24, 2007 at 09:50:08AM +0100, Stephen Hemminger wrote:
> > The problem is related to power management. The PHY has a number of PCI configuration
> > registers for power control, and the function of these changes based on the version and
> > revision of the chip. The driver does work on older versions of the EC-U, in
> > Fujitsu laptop's, it is just the new rev that is broken.
> >
> > The driver should probably fail smarter (by not loading) if the PHY isn't powered
> > up correctly, but that doesn't help your problem.
> >
> > The vendor has provided me with documentation on many versions
> > of the chip, but I don't have doc's on the lastest revision differences of the EC Ultra,
> > so a proper solution is not easily available.  The best method for resolving this would
> > be to first try the vendor driver version of sk98lin and see if that fixes it. If so,
> > then it is easy to change sky2, to match the phy setup in the vendor driver.
> > Another possibility is to look for places in sky2 driver where there are places
> > that compare version/revision.
> >
> > The most likely bits that need to change are in PCI registers: 0x80, 0x84 and 0x88
> > You could also load the windows driver and dump PCI config space (with lspci from
> > cygwin), and see what the settings are there.
> >
> > I am away from my office for a month, and therefore away from any sky2
> > hardware for testing.
>
> I'll try the above and keep you posted. The crash itself seems to be a
> 2.6.23-rc1 regression though. I never experienced this with 2.6.22-rc5
> which i was running before.

Can you try to figure out what is causing this crash and then use git-bisect?

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
