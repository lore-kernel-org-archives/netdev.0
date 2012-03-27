From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Tue, 27 Mar 2012 18:29:58 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580DC68D@ORSMSX105.amr.corp.intel.com>
References: <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
 <20120324065147.GB2201@netboy.at.omicron.at>
 <CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
 <20120326152730.GA10212@localhost.localdomain>
 <CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DC04D@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS4Jqe5ZcZyGZjurmjBCgzj=+a0cgHAEwB+esXNoQ3P7NQ@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DC1A0@ORSMSX105.amr.corp.intel.com>
 <20120327180501.GA3878@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: chetan loke <loke.chetan@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30701 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754802Ab2C0SaA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 14:30:00 -0400
In-Reply-To: <20120327180501.GA3878@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Tuesday, March 27, 2012 11:05 AM
> To: Keller, Jacob E
> Cc: chetan loke; netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net;
> Kirsher, Jeffrey T; Ronciak, John; john.stultz@linaro.org; tglx@linutronix.de
> Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
> timecompare method
> 
> I really doubt you will see any performance gain from such a change. It
> increases code complexity and size for some dubious, theoretical performance
> gain, for some really whacked use case.
> 
> Richard
> 
> 

It isn't so much about performance gains as it is about preventing poorly written user apps from stalling the clean descriptor routines. I am working on a test case that should prove whether this is even an issue (at least with ixgbe). Once I have data on that it can be determined if the extra lock would alleviate it. The conceptual issue is that spamming get-time could cause the clean tx/rx irq routines to stall inside the interrupt for too long. (thereby not freeing up descriptors on the ring to allow more packets). While performance is an issue, I don't feel that it can be brushed off as "performance loss due to feature" unless I can show that it isn't very easy to trip, or doesn't cause a major issue. Once I know the data, it can be determined what the right approach is.
