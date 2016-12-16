From: "Chickles, Derek" <Derek.Chickles@cavium.com>
Subject: RE: [PATCH] liquidio CN23XX: make timeout HZ independent
Date: Fri, 16 Dec 2016 20:08:04 +0000
Message-ID: <MWHPR07MB294310204EE20FC19B8E8612F39C0@MWHPR07MB2943.namprd07.prod.outlook.com>
References: <1481875839-30860-1-git-send-email-hofrat@osadl.org>
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
Received: from mail-dm3nam03on0054.outbound.protection.outlook.com ([104.47.41.54]:55495
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757317AbcLPUII (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 15:08:08 -0500
In-Reply-To: <1481875839-30860-1-git-send-email-hofrat@osadl.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Nicholas Mc Guire [mailto:hofrat@osadl.org]
> Sent: Friday, December 16, 2016 12:11 AM
> To: Chickles, Derek
> Cc: Burla, Satananda; Manlunas, Felix; Vatsavayi, Raghu;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Nicholas Mc Guire
> Subject: [PATCH] liquidio CN23XX: make timeout HZ independent
>=20
> schedule_timeout_* takes a timeout in jiffies but the code currently is
> passing in a constant which makes this timeout HZ dependent, so pass it
> through msecs_to_jiffies() to fix this up.
>=20
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> ---
>=20
> Problem found by coccinelle spatch
>=20
> The current delay can vary by a factor 10 depending on the HZ
> setting chose, which does not seem reasonable here.
>=20
> The below patch sets the timeout to 10ms - it is though not clear
> if this is the intent or if it should be longer/shorter as it is not
> clear what HZ setting was assumed during design and used for testing.
>=20
> This needs an ack by someone who knows the device and can confirm that
> 10ms is reasonable to wait for completion of queuing.

We were actually looking at this in parallel already to speed up driver
loading. It would be better if we changed LIO_MBOX_WRITE_WAIT_TIME
to 1 and applied the msecs_to_jiffies() to the line specified in your patch
and the loop just above that.

        while (readq(mbox->mbox_write_reg) !=3D OCTEON_PFVFSIG) {
                schedule_timeout_uninterruptible(LIO_MBOX_WRITE_WAIT_TIME);
                if (count++ =3D=3D LIO_MBOX_WRITE_WAIT_CNT) {
                        ret =3D OCTEON_MBOX_STATUS_FAILED;
                        break;
                }
        }      =20

If you can provide a new patch with both the changes we'll sign off on it.
Otherwise, it's on our list and we'll submit it soon ourselves.

Thanks,
Derek
