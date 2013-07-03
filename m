From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Huaei E3131 - connected!
Date: Wed, 03 Jul 2013 09:13:43 +0200
Message-ID: <87mwq4w1y0.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
	<87wqp9xja5.fsf@nemi.mork.no>
	<alpine.LNX.2.02.1307021855270.19053@eeeadesso>
	<alpine.LNX.2.02.1307022202570.26010@eeeadesso>
	<alpine.LNX.2.02.1307022207060.26010@eeeadesso>
	<alpine.LNX.2.02.1307022210470.26010@eeeadesso>
	<alpine.LNX.2.02.1307022213380.26010@eeeadesso>
	<alpine.LNX.2.02.1307030836270.12831@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51361 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767Ab3GCHOD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 03:14:03 -0400
In-Reply-To: <alpine.LNX.2.02.1307030836270.12831@eeeadesso> (Enrico Mioso's
	message of "Wed, 3 Jul 2013 08:40:16 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> Hi guys!
> there's a problem ... I don't understand why even looking at the code=
 (sure, I=20
> will look at it again): but, bringing up the wwan0 interface simply w=
orks. So=20
> now I'm sending this mail via the device's wwan interface and while l=
ooking and=20
> typing to the wdm character device, without any apparent problem.
> I did not implement the status handler, but the driver seems to be ab=
le to=20
> work, probably missing some notifications?
> This needs to be EXTRENSIVELY polished and reviewed - but it's encour=
aging!


Great work!

The NCM notifications should be handled, but I don't think it is crucia=
l
to have that in place for the initial version of the driver. Adding tha=
t
support means changing the cdc-wdm API, which need some careful plannin=
g
and time because cdc-wdm is in another subsystem (usb vs net).

Since this driver is not dealing with NCM conformant devices, but only
implementing a NCM like vendor specific protocol, I believe it is
acceptable to handle the notifcations as "phase 2" of the driver.

In my opinion, all you need to do before submitting is fixup the device
list, moving the Huawei vendor specific entries from cdc_ncm to this
driver.  You might as well do that as part of introducing the driver.
Or make it a separate final patch if you prefer.



Bj=C3=B8rn
