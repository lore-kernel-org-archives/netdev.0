From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] net: fix __netdev_update_features return on
 ndo_set_features failure
Date: Tue, 17 Nov 2015 15:31:26 +0100
Message-ID: <564B3A3E.50905@cumulusnetworks.com>
References: <1447424424-4419-1-git-send-email-razor@blackwall.org>
 <20151117135418.GA30197@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38566 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbbKQOb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 09:31:29 -0500
Received: by wmec201 with SMTP id c201so28744032wme.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 06:31:28 -0800 (PST)
In-Reply-To: <20151117135418.GA30197@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2015 02:54 PM, Micha=B3 Miros=B3aw wrote:
> On Fri, Nov 13, 2015 at 03:20:24PM +0100, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> If ndo_set_features fails __netdev_update_features() will return -1 =
but
>> this is wrong because it is expected to return 0 if no features were
>> changed (see netdev_update_features()), which will cause a netdev
>> notifier to be called without any actual changes. Fix this by return=
ing
>> 0 if ndo_set_features fails.
>=20
> Hmm. In case ndo_update_features() failed it might have changed the f=
eatures.
> The assumption I made was that we're better off initiating spurious n=
otification
> than miss one. This is an unlikely event - a bug in a driver or probl=
em with the HW.
>=20
> Best Regards,
> Micha=B3 Miros=B3aw
>=20

Hmm, good point. I went over a dozen drivers and I can see that some mi=
ght
actually do that (e.g. bnx2x in bnx2x_set_features()). It's rare but po=
ssible,
most of them return only 0.
Okay then, I'll revert this change and add a comment with this so it's =
clear
in the future.

Thanks for the feedback,
 Nik
