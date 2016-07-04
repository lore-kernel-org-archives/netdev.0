From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net,stable] cdc_ncm: workaround for EM7455 "silent" data interface
Date: Mon, 04 Jul 2016 13:40:10 +0200
Message-ID: <87h9c5638l.fsf@nemi.mork.no>
References: <1467577490-27810-1-git-send-email-bjorn@mork.no>
	<1467619605.9978.4.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60164 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753161AbcGDMBz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 08:01:55 -0400
In-Reply-To: <1467619605.9978.4.camel@suse.com> (Oliver Neukum's message of
	"Mon, 04 Jul 2016 10:06:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:
> On Sun, 2016-07-03 at 22:24 +0200, Bj=C3=B8rn Mork wrote:
>> Several Lenovo users have reported problems with their Sierra
>> Wireless EM7455 modem. The driver has loaded successfully and
>> the MBIM management channel has appeared to work, including
>> establishing a connection to the mobile network. But no frames
>> have been received over the data interface.
>
> If this is needed in open() it must also be needed in reset_resume()

reset_resume needs fixing in general. This is completely unrelated to
this bug. In fact, as we don't do any NCM control messages there in the
current resume, I'm not sure this firmware bug is triggered by it.  But
it's untestable, because:

reset_resume cannot work for MBIM. At least not with the driver/userspa=
ce
model we have chosen.  The driver does not have enough information abou=
t
the device state to recreate it.  It could maybe work for NCM, but I
don't think it currently does.  The NCM protocol requires some minimum
driver and device negotiation, and the current NCM .reset_resume points
to usbnet_resume which completely ignores that.

Proposals for fixing reset_resume would of course be good, and I'll
think about how to deal with it, but I don't think it should block
fixing the current issue.  They are not related.


Bj=C3=B8rn
