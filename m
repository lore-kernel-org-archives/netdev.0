From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 3 Feb 2011 15:54:00 -0800
Message-ID: <AANLkTi=Zxp3VGt266MZ+NVmSFQhtnmUxPBFV_t2hcObZ@mail.gmail.com>
References: <20110202.170750.229739784.davem@davemloft.net> <alpine.DEB.2.00.1102040027060.25125@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	"H.K. Jerry Chu" <hkjerry.chu@gmail.com>,
	Nandita Dukkipati <nanditad@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:32166 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461Ab1BCXyX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 18:54:23 -0500
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p13NsMDg018895
	for <netdev@vger.kernel.org>; Thu, 3 Feb 2011 15:54:22 -0800
Received: from vxb37 (vxb37.prod.google.com [10.241.33.101])
	by wpaz9.hot.corp.google.com with ESMTP id p13NrnTO016146
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 3 Feb 2011 15:54:21 -0800
Received: by vxb37 with SMTP id 37so527133vxb.33
        for <netdev@vger.kernel.org>; Thu, 03 Feb 2011 15:54:21 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1102040027060.25125@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 3, 2011 at 2:43 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
> It would perhaps be useful to change receiver advertized window to in=
clude
> some extra segs initially. It should be >=3D IW + peer's dupThresh-1 =
as
That's a very good point.

Maybe IRW should be IW + ssthresh - 1 since Linux also performs
limited-transmit during fast-recovery as described in RFC 3517. This
way sender can keep sending new data during the recovery as long as
cwnd allows.

> otherwise limited transmit won't work for the initial window because =
we
> won't open more receiver window with dupacks (IIRC, I suppose Jerry m=
ight
> be able to correct me right away if I'm wrong and we open window with
> dupacks too?). =A0I think initial receiver window code used to have s=
ome
> surplus but it was broken by the rfc3390-func conversion (against my
> advice on how to do the conversion).
>
> --
> =A0i.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
