From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 23 Aug 2012 16:09:30 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823110357.GB2238@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16010 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160Ab2HWQJd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 12:09:33 -0400
In-Reply-To: <20120823110357.GB2238@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, August 23, 2012 4:04 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Vick, Matthew; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
> 
> On Thu, Aug 23, 2012 at 02:56:50AM -0700, Jeff Kirsher wrote:
> > From: Matthew Vick <matthew.vick@intel.com>
> >
> > For users without CONFIG_IGB_PTP=y, we should not be compiling any
> PTP
> > code into the driver. Tidy up the wrapping in igb to support this.
> 
> Actually, you are doing more than that. You are adding a bunch of
> comments onto the already existing #endifs.

Fair enough. Would you like me to update the patch description?

> > +#ifdef CONFIG_IGB_PTP
> >  	struct ptp_clock *ptp_clock;
> >  	struct ptp_clock_info caps;
> >  	struct delayed_work overflow_work;
> >  	spinlock_t tmreg_lock;
> >  	struct cyclecounter cc;
> >  	struct timecounter tc;
> > +#endif /* CONFIG_IGB_PTP */
> > +
> 
> This is legitimate, to reduce memory footprint.
> 
> [...]
> 
> But this is just churn. You aren't actually improving anything here. It
> is already clear that the #endif belongs to the #ifdef just three lines
> above.
> 
> If you are on some kind of campaign to comment all the endifs, then you
> should say so, and, to be consistent, you should not overlook the
> CONFIG_IGB_DCA blocks.
> 
> But I think it really isn't needed.
> 
> Thanks,
> Richard

I'm willing to work on a follow on patch to add proper endings to CONFIG_IGB_DCA blocks. The reasoning here was "I'm working on the wrapping for the code here anyway, so I might as well make it consistent."

Personally, I think it is an improvement. If you want to add #endif comments, you may as well be consistent about it.

Cheers,
Matthew
