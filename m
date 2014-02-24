From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net 4/5] be2net: wait longer to reap TX compls in
 be_close()
Date: Mon, 24 Feb 2014 12:08:17 +0000
Message-ID: <a9644286-d102-4645-96c7-4961379f8033@CMEXHTCAS2.ad.emulex.com>
References: <57bc5399-f8f6-4c65-8cae-131c83d548ad@CMEXHTCAS1.ad.emulex.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6C9608@AcuExch.aculab.com>
 <d3bd3dc1-8e29-4388-bbd3-e4af196d592b@CMEXHTCAS2.ad.emulex.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6C98FD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Vasundhara Volam <Vasundhara.Volam@Emulex.Com>
To: David Laight <David.Laight@ACULAB.COM>,
	Somnath Kotur <Somnath.Kotur@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:17838 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbaBXMIX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 07:08:23 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6C98FD@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> 
> > From: Sathya Perla
> > > From: David Laight [mailto:David.Laight@ACULAB.COM]
> > >
> > > From: Of Somnath Kotur
> > > > be_close() currently waits for a max of 200ms to receive all pending
> > > > TX compls. This timeout value was roughly calcuated based on 10G
> > > > transmission speeds and the TX queue depth. This timeout may not be
> > > > enough when the link is operating at lower speeds or in
> > > > multi-channel/SR-IOV configs with TX-rate limiting setting.
> > > > Increase the timeout to 2000ms and also bail-out if there is
> > > > a HW-error.
> > >
> > > What about monitoring whether transmits are actually completing,
> > > and giving up if none are completed within a suitable time period?
> > >
> >
> > David, the code already does that. All the queues are checked for
> > any new TX compls each 1ms in the be_close()->be_tx_compl_clean()
> > path. This patch is not changing that logic.
> 
> Yes, but it might be better to modify the logic rather than just
> increase the timeout.
> 
> The code is waiting for any pending transmits to complete.
> The purpose of the timeout is to give up if the transmits aren't going
> to complete.
> So instead of assuming that a specific interval is long enough, abort
> if no transmits completed in (say) a 10ms period.
> Move the sleep() to the top of the loop and abort if nothing is found
> on any queue.
> Oh and move the zeroing of cmpl and num_wrbs to a sensible place.

So you're saying, keep polling on completions till the HW has been
completely silent for a particular (you mention 10ms) period of time.

This does sound like a nicer scheme. Thanks!
Will implement this and re-post the patch.

-Sathya
