From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [net PATCH] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Wed, 30 Mar 2016 11:38:27 -0700
Message-ID: <20160330113827.00002967@unknown>
References: <20160330064213.12927.46852.stgit@localhost.localdomain>
	<20160330170011.GB27540@oracle.com>
	<CAKgT0UdTgaeamyLetGPK0mqMNS-80BTc8t-WdSGJuuLDfz4JOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	jesse.brandeburg@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12164 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752701AbcC3Sie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 14:38:34 -0400
In-Reply-To: <CAKgT0UdTgaeamyLetGPK0mqMNS-80BTc8t-WdSGJuuLDfz4JOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Mar 2016 10:12:51 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Wed, Mar 30, 2016 at 10:00 AM, Sowmini Varadhan
> <sowmini.varadhan@oracle.com> wrote:
> > On (03/29/16 23:44), Alexander Duyck wrote:
> >> This patch has been sanity checked only.  I cannot yet guarantee it
> >> resolves the original issue that was reported.  I'll try to get a
> >> reproduction environment setup tomorrow but I don't know how long that
> >> should take.
> >
> > I tried this out with rds-stress on my test-pair, unfortunately, I
> > still see the Tx hang.
> >
> > Setting up the test is quite easy- for reference, the instructions
> > are here:
> >    https://sourceforge.net/p/e1000/mailman/message/34936766/
> 
> Yeah.  The patch was sort of a knee-jerk reaction to being told that
> the patch referenced caused a regression.  From what I can tell that

Thanks for working so hard on the patch Alex, I need to apologize, as
the original test appears to fail as well with 1.3.46-k (a previous
driver to your patch) and I thought we had already tested that, but I
was wrong.

This is not a regression, but likely just an undetected "bug" that we
need to work out.

> is not the case as I am also seeing the Tx hangs when I run the test
> with the frames being linearized.

That doesn't make much sense unless it is something about how we are
setting up the offload.  I troubleshoot by disabling the PFR from the
MDD code, then disabling tx timeout via debugfs, and using debugfs to
dump the descriptor ring after the MDD event fires.
 
> I'll do some research this morning to see if I can find a root cause.
> Unfortunately the malicious driver detection isn't very well
> documented so I can't be certain what is causing it to be triggered.

I'm still looking at this too and appreciate the help.
