From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [PATCH 6/9] RDS: Fix ordering in a conditional
Date: Mon, 30 Mar 2009 23:56:14 -0700
Message-ID: <c0a09e5c0903302356m688fd370k65151f99f43dfdfc@mail.gmail.com>
References: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
	 <1238438693-29540-7-git-send-email-andy.grover@oracle.com>
	 <adak566e2pi.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Grover <andy.grover@oracle.com>, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:43372 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbZCaG4Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 02:56:16 -0400
Received: by qw-out-2122.google.com with SMTP id 8so2957968qwh.37
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 23:56:14 -0700 (PDT)
In-Reply-To: <adak566e2pi.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2009 at 9:27 PM, Roland Dreier <rdreier@cisco.com> wrot=
e:
> =A0> - =A0 =A0if (0 <=3D ret && (unsigned) ret < nr_pages) {
> =A0> + =A0 =A0if (ret > 0 && (unsigned) ret < nr_pages) {
>
> This is not an equivalent transformation -- the original code is true=
 if
> ret =3D=3D 0, while the new code is false.

Ah! Good point.

> Also it seems you don't need the unsigned cast here, since the clause
> before just checked that ret is positive?

True, but I'd bet the compiler will warn if we remove it. I'll try it
tomorrow and see.

Thanks! -- Regards -- Andy
