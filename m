From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH net] cdc_ether: Ignore bogus union descriptor for RNDIS devices
Date: Thu, 26 Apr 2012 13:56:02 +0200
Message-ID: <201204261356.03000.oliver@neukum.org>
References: <201204260931.30327.oliver@neukum.org> <1335437703-6800-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Markus Kolb <linux-201011@tower-net.de>,
	Iker =?utf-8?q?Salm=C3=B3n_San_Mill=C3=A1n?=
	<shaola@esdebian.org>, Jonathan Nieder <jrnieder@gmail.com>,
	655387@bugs.debian.org, stable@vger.kernel.org
To: =?utf-8?q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:52022 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab2DZMAH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 08:00:07 -0400
In-Reply-To: <1335437703-6800-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 26. April 2012, 12:55:03 schrieb Bj=C3=B8rn Mork:
> Some RNDIS devices include a bogus CDC Union descriptor pointing
> to non-existing interfaces.  The RNDIS code is already prepared
> to handle devices without a CDC Union descriptor by hardwiring
> the driver to use interfaces 0 and 1, which is correct for the
> devices with the bogus descriptor as well. So we can reuse the
> existing workaround.

Very good, except that this is a bit risky, because we may use
interface 0 without checking that it belongs to us. Could you
add a sanity check that the interface for which probe() is called
is really the control interface in case a workaround is used?

	Regards
		Oliver
