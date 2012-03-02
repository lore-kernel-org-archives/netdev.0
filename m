From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.3.0-rc5: OOps in dql_completed (Broadcom tg3 driver)
Date: Fri, 02 Mar 2012 06:30:46 -0800
Message-ID: <1330698646.2469.28.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1203011505510.6685@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>
To: Christoph Lameter <cl@gentwo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1203011505510.6685@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 01 mars 2012 =C3=A0 15:13 -0600, Christoph Lameter a =C3=A9cri=
t :
> Dell R620. 2x 2.9Ghz Sandybridge
>=20
> Sadly I could only get a screenshot and the top of the dump has scrol=
led
> off the system.
>=20

Thanks Christoph for this report.

Tom, dql_queued() assumes caller checked availability in the queue with
dql_avail(), but its not the case if tg3_tso_bug() is called.

        do {
                nskb =3D segs;
                segs =3D segs->next;
                nskb->next =3D NULL;
                tg3_start_xmit(nskb, tp->dev);
        } while (segs);

In case we hit BQL limit in one of the tg3_start_xmit() calls, we shoul=
d
'abort' the following ones, dont you think ?

Or maybe thats irrelevant, and only dql_queued() comment is wrong.

Thanks
