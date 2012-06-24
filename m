From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sun, 24 Jun 2012 19:47:30 +0200
Message-ID: <0e34226c-8fe7-4e2e-8fc2-2ed140f23e9b@email.android.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no> <201206232255.08319.oliver@neukum.org> <877guxhx44.fsf@nemi.mork.no> <201206241413.08339.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming@gmail.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius__Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:32929 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244Ab2FXRsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jun 2012 13:48:08 -0400
In-Reply-To: <201206241413.08339.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> wrote:
>Am Sonntag, 24. Juni 2012, 11:34:19 schrieb Bj=C3=B8rn Mork:
>
>> Sorry, I did not understand what you meant we should do here.  The
>extra
>> usb_set_intfdata(, NULL) in usbnet_disconnect() won't make any
>> difference for that piece of code, will it?
>
>The point is that if it may be set to NULL, we always want it to be se=
t
>to
>NULL, so we catch bugs.
>
>> And the USB core ensures that intfdata is set to NULL before any
>> reprobing, so that will never be a problem.  That's the reason why i=
t
>> seems redundant setting it in usbnet_disconnect().
>
>The point is that if there is a problem because intfdata is set to
>NULL,
>there is very likely a problem in form of a race condition, if intfdat=
a
>were not set to NULL in usbnet's disconnect handler.

Thanks for explaining. Yes, that makes sense to me as well.

So then the original patch against qmi_wwan should go in, and we should=
 leave usbnet as it is. Are everyone comfortable with that?


Bj=C3=B8rn
