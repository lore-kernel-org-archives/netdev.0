From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Is this 32-bit NCM?
Date: Fri, 28 Nov 2014 10:29:09 +0100
Message-ID: <87ppc71xne.fsf@nemi.mork.no>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
	<87ppc957h1.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1411271037050.9464@gmail.com>
	<874mtl55ar.fsf@nemi.mork.no>
	<CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
	<alpine.LNX.2.03.1411271932510.1548@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Strizhevsky <alexxst@gmail.com>,
	ShaojunMidge.Tan@audiocodes.com, Mingying.Zhu@audiocodes.com,
	youtux@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Eli.Britstein@audiocodes.com
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41554 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035AbaK1J3W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 04:29:22 -0500
In-Reply-To: <alpine.LNX.2.03.1411271932510.1548@gmail.com> (Enrico Mioso's
	message of "Thu, 27 Nov 2014 19:34:46 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> What I suspect, is that all this mess started when Huawei introduce n=
ew=20
> firmware releases that changed something in the IPV6 support.
> Bjorn - do you remember when a guy called Thomas reported us a proble=
m about an=20
> LTE huawei modem that wasn't working with huawei_cdc_ncm?
> And you then discovered the problem was originated from some changes =
in the=20
> ordering of cdc_ncm actions; what happened then?
> Did Thomas get his modem back to working state?

yes, that bug was fixed by

commit ff0992e9036e9810e7cd45234fa32ca1e79750e2
Author: Bj=C3=B8rn Mork <bjorn@mork.no>
Date:   Mon Mar 17 16:25:18 2014 +0100

    net: cdc_ncm: fix control message ordering
   =20
    This is a context modified revert of commit 6a9612e2cb22
    ("net: cdc_ncm: remove ncm_parm field") which introduced
    a NCM specification violation, causing setup errors for
    some devices. These errors resulted in the device and
    host disagreeing about shared settings, with complete
    failure to communicate as the end result.
   =20
    The NCM specification require that many of the NCM specific
    control reuests are sent only while the NCM Data Interface
    is in alternate setting 0. Reverting the commit ensures that
    we follow this requirement.
   =20
    Fixes: 6a9612e2cb22 ("net: cdc_ncm: remove ncm_parm field")
    Reported-and-tested-by: Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi>
    Reported-by: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
    Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
    Signed-off-by: David S. Miller <davem@davemloft.net>



Bj=C3=B8rn
