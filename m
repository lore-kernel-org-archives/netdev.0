From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Bug#690845: ethtool: incorrect WoL detection on Broadcom NX
 II rev < 12
Date: Mon, 22 Oct 2012 19:18:07 -0700
Message-ID: <1350958687.8764.170.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <20121018134717.9579.22997.reportbug@palomino.museglobal.com>
 <1350570748.26833.102.camel@deadeye.wl.decadent.org.uk>
 <CAG2Wgfee=qsiUhAk5reYTypcOZL0kM5A58J+LjB1wuQ_k9FrfA@mail.gmail.com>
 <1350610209.22276.6.camel@deadeye.wl.decadent.org.uk>
 <1350675530.8764.131.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CAG2Wgfdn52R2FYh77-2ZHCFVwe8d0MOv_4but6aOsU50jF-+Lg@mail.gmail.com>
 <1350946459.8764.145.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <1350956707.5283.48.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: 690845@bugs.debian.org, "Teodor MICU" <mteodor@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: "Ben Hutchings" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2257 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932498Ab2JWCSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 22:18:16 -0400
In-Reply-To: <1350956707.5283.48.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-23 at 02:45 +0100, Ben Hutchings wrote: 
> Well we knew that much!  Is the problem that the system firmware 'owns'
> the WoL control registers so the host can't safely change them?  Is it
> possible to *read* the WoL configuration, if not to change it? 

It's a hardware problem and I don't understand all the details.  There
is an internal PCIX to PCIE bridge on this chip and it gates the NIC's
PME event.  During S5 reset, the bridge gets reset by the BIOS and the
WoL setting done by the driver will no longer work.  Newer chip revs
have fixed the problem in hardware.

The driver reads the pre-boot WoL setting from NVRAM and it becomes the
ethtool WoL default setting.  Apparently, it is also not working in this
case.  I know that it doesn't work on some LOM designs as the setting is
actually in BIOS NVRAM as opposed to NIC NVRAM.
