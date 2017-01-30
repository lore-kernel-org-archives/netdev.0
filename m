From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Mon, 30 Jan 2017 14:34:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0273BA8@AcuExch.aculab.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Yuval.Mintz@cavium.com" <Yuval.Mintz@cavium.com>
To: 'Richard Cochran' <richardcochran@gmail.com>,
        Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:65084 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753526AbdA3OeY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 09:34:24 -0500
In-Reply-To: <20170129153536.GD2223@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Richard Cochran
> Sent: 29 January 2017 15:36
...
> > +static int qede_ptp_adjfreq(struct ptp_clock_info *info, s32 ppb)
> > +{
> > +	struct qede_ptp *ptp = container_of(info, struct qede_ptp, clock_info);
> > +	struct qede_dev *edev = ptp->edev;
> > +	int rc;
> > +
> > +	__qede_lock(edev);
> > +	if (edev->state == QEDE_STATE_OPEN) {
> > +		spin_lock_bh(&ptp->lock);
> > +		rc = ptp->ops->adjfreq(edev->cdev, ppb);
> 
> Why add this extra layer of indirection?

There might be two extra layers of indirection!

One can be removed by copying the function vector instead of referencing it.
So that call would be ptp->ops.adjfreq(...).

Even from the later emails I can't see which way around that call is.
How many different implementations of 'ops->adjfreq' are there?
If there is only one you don't need an indirect call.

	David
