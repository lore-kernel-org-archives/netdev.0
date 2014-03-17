From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
Date: Mon, 17 Mar 2014 14:10:44 +0100
Message-ID: <8738ihm0mj.fsf@nemi.mork.no>
References: <1394746907.15946.8.camel@dcbw.local>
	<20140313220812.GW3200@reaktio.net>
	<20140314075548.GX3200@reaktio.net> <87wqfxnppc.fsf@nemi.mork.no>
	<20140314084159.GA3200@reaktio.net> <87siqlnol8.fsf@nemi.mork.no>
	<20140314090525.GB3200@reaktio.net> <87ob19nndo.fsf@nemi.mork.no>
	<20140314125934.GC3200@reaktio.net> <87vbvgnbv3.fsf@nemi.mork.no>
	<20140314142559.GD3200@reaktio.net> <87k3btm57a.fsf@nemi.mork.no>
	<877g7tm1an.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas =?utf-8?Q?Sch=C3=A4fer?= <tschaefer@t-online.de>,
	Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34882 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933312AbaCQNLL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 09:11:11 -0400
In-Reply-To: <877g7tm1an.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Mon, 17
	Mar 2014 13:56:16 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> But looking closer, I see that the SET_NTB_FORMAT returned -EPIPE,
> i.e. stall.  The driver currently ignores this error, which is why we
> end up with different device and host settings.=20
>
> Anyone know what the proper driver action is? Note that this error
> cannot happen with a spec conforming device, because SET_NTB_FORMAT
> support is required for devices claiming 32 bit support.  So the spec
> doesn't tell us what to do.

=46..k!  OK, my fault.  Proper fix coming up ASAP.

I believe commit 6a9612e2cb22 "net: cdc_ncm: remove ncm_parm field"
messed up big time, because of my lack of understanding of the
importance of control message ordering in this driver, and additional
sloppy spec reading.

Quoting from section 6.2.5 "SetNtbFormat":

 "The host shall only send this command while the NCM Data Interface is
  in alternate setting 0.

The referenced commit moved the call to cdc_ncm_setup() *after*
the usb_set_interface() for the data interface.  This is likely the
cause of the failure.

Thomas: This is probably what made your devices stop work after v3.12 a=
s
well.  The bug was introduced with v3.13.


Bj=C3=B8rn
