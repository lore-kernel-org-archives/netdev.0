From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH vringh 2/2] caif_virtio: Introduce caif over virtio
Date: Tue, 19 Feb 2013 09:00:13 +1030
Message-ID: <87ppzxi7be.fsf@rustcorp.com.au>
References: <1360494273-27889-1-git-send-email-sjur.brandeland@stericsson.com> <1360494273-27889-3-git-send-email-sjur.brandeland@stericsson.com> <87vc9zfic8.fsf@rustcorp.com.au> <81C3A93C17462B4BBD7E272753C105792458EDD161@EXDCVYMBSTM005.EQ1STM.local> <87ehgklds9.fsf@rustcorp.com.au> <CAJK669YQ+x5zXSZA1FQHkRrcCt+SgZP-M_ea-Ey8ziGLhq9cqQ@mail.gmail.com> <87bobmjish.fsf@rustcorp.com.au> <CAJK669ZATh8FojTGdFH_x7ovMvA2L7XFUratiptJmPFZPhv31g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ohad Ben-Cohen <ohad@wizery.com>,
	Vikram ARV <vikram.arv@stericsson.com>,
	Dmitry TARNYAGIN <dmitry.tarnyagin@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Erwan YVIN <erwan.yvin@stericsson.com>,
	"virtualization\@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Ido Yariv <ido@wizery.com>, <mst@redhat.com>
To: Sjur =?utf-8?Q?Br=C3=A6ndeland?= <sjurbren@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJK669ZATh8FojTGdFH_x7ovMvA2L7XFUratiptJmPFZPhv31g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sjur Br=C3=A6ndeland <sjurbren@gmail.com> writes:

>> Sjur Br=C3=A6ndeland <sjurbren@gmail.com> writes:
>>> How about supporting struct vringh_kiov and struct kvec as well?
>>> I currently get the following complaints with my V2 patch-set:
>>>
>>> drivers/net/caif/caif_virtio.c:486:2: warning: passing argument 1 o=
f
>>> =E2=80=98vringh_iov_init=E2=80=99 from incompatible pointer type [e=
nabled by default]
>>
>> vringh_kiov_init()?  Did I miss something else?
>
> I get a warning for my useof vringh_iov_cleanup() in
> addition to the one above.
>
> How about adding kiov variants of  vringh_iov_cleanup()
> and vringh_iov_reset() as well?

Hmm, I have those here too (in the header):

+static inline void vringh_kiov_reset(struct vringh_kiov *kiov)
+{
+	kiov->off =3D 0;
+	kiov->i =3D 0;
+}
+
+static inline void vringh_kiov_cleanup(struct vringh_kiov *kiov)
+{
+	if (kiov->max_num & VRINGH_IOV_ALLOCATED)
+		kfree(kiov->iov);
+	kiov->max_num =3D kiov->used =3D kiov->i =3D kiov->off =3D 0;
+	kiov->iov =3D NULL;
+}

I've folded the patches and put them into my pending-rebases branch,
ready for virtio-next.

I'd really like MST's ack on this, too, so I'll repost the series.

Cheers,
Rusty.
