From: "Chickles, Derek" <Derek.Chickles@cavium.com>
Subject: RE: [PATCH RFC] liquidio: make timeout HZ independent
Date: Fri, 16 Dec 2016 17:53:27 +0000
Message-ID: <MWHPR07MB29439215E51F4AFB7DE359C3F39C0@MWHPR07MB2943.namprd07.prod.outlook.com>
References: <1481871440-24859-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Burla, Satananda" <Satananda.Burla@cavium.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0068.outbound.protection.outlook.com ([104.47.34.68]:19088
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758253AbcLPS1p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 13:27:45 -0500
In-Reply-To: <1481871440-24859-1-git-send-email-hofrat@osadl.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Nicholas Mc Guire [mailto:hofrat@osadl.org]
> Sent: Thursday, December 15, 2016 10:57 PM
> To: Chickles, Derek
> Cc: Burla, Satananda; Manlunas, Felix; Vatsavayi, Raghu;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Nicholas Mc Guire
> Subject: [PATCH RFC] liquidio: make timeout HZ independent
>=20
> schedule_timeout_* takes a timeout in jiffies but the code currently is
> passing in a constant which makes this timeout HZ dependent, so pass it
> through msecs_to_jiffies() to fix this up.
>=20
> Fixes: commit b0d66369edcd ("liquidio VF error handling")
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> ---
>=20
> Problem found by coccinelle spatch
>=20
> The current wait time can vary by a factor 10 depending on the HZ
> setting chose, which does not seem reasonable here.
>=20
> The below patch sets the timeout to 100ms - it is though not clear
> if this is the intent or if it should be longer/shorter as it is not
> clear what HZ setting was assumed during design and used for testing.
>=20
> This needs an ack by someone who knows the device and can confirm that
> 100ms is reasonable to wait for completion of in-flight requests.

Yes, 100ms was the intent here.

Thanks for catching this.

Derek
