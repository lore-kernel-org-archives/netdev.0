From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 12 Feb 2017 15:53:44 +0000
Message-ID: <BL2PR07MB23069BEC54C9CD563356BA8D8D460@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
 <20170211111638.GA6564@localhost.localdomain>
 <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170212140202.GA1702@localhost.localdomain>
 <BL2PR07MB2306751ABE3FC347E40302B18D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0075.outbound.protection.outlook.com ([104.47.36.75]:31376
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751226AbdBLPxr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 10:53:47 -0500
In-Reply-To: <BL2PR07MB2306751ABE3FC347E40302B18D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The original would return val =3D=3D 1, period =3D=3D 62499999; While thi=
s does have
> some error [val / (period * 16 + 8) is slightly bigger than 1 / 10^9, err=
or at
> 18[?] digit after dot], it's the best we can configure for the HW.

Correction. That's actually not *the best* we could configure -
 due to stopping at the first value between equal differences.
[you've already commented on that in the past, mentioning  that we
should use >=3D and not >].

But that doesn't change the fact that your approximation can choose
numbers which can't be configured to the HW, and as a result incorrectly
pick some that will not minimize the approximation error.

> One simple adjustment we could do is simply break from the loop If 'diff =
=3D=3D
> 0'. At least for small PPB value this would be hit relatively quickly.

Given the previous correction, the suggestion would also include
reversing the order of the iteration [7 -> 1 instead of 1 -> 7].
