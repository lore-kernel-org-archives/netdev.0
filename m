From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net] net: fix __netdev_update_features return on
 ndo_set_features failure
Date: Tue, 17 Nov 2015 14:54:18 +0100
Message-ID: <20151117135418.GA30197@rere.qmqm.pl>
References: <1447424424-4419-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:60373 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbbKQOAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 09:00:50 -0500
Content-Disposition: inline
In-Reply-To: <1447424424-4419-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2015 at 03:20:24PM +0100, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>=20
> If ndo_set_features fails __netdev_update_features() will return -1 b=
ut
> this is wrong because it is expected to return 0 if no features were
> changed (see netdev_update_features()), which will cause a netdev
> notifier to be called without any actual changes. Fix this by returni=
ng
> 0 if ndo_set_features fails.

Hmm. In case ndo_update_features() failed it might have changed the fea=
tures.
The assumption I made was that we're better off initiating spurious not=
ification
than miss one. This is an unlikely event - a bug in a driver or problem=
 with the HW.

Best Regards,
Micha=B3 Miros=B3aw
