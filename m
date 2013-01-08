From: Andy Walls <awalls@md.metrocast.net>
Subject: Re: [PATCH 5/5] kfifo: log based kfifo API
Date: Tue, 08 Jan 2013 16:10:07 -0500
Message-ID: <f1be90be-ad99-4dff-8332-804383adc5c8@email.android.com>
References: <1357657073-27352-1-git-send-email-yuanhan.liu@linux.intel.com> <1357657073-27352-6-git-send-email-yuanhan.liu@linux.intel.com> <20130108181645.GA7972@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, Stefani Seibold <stefani@seibold.net>,
        Andrew Morton <akpm@linux-foundation.org>, linux-omap@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, platform-driver-x86@vger.kernel.org,
        linux-input@vger.kernel.org, linux-iio@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-media@vger.kernel.org,
        linux-mmc@vger.kernel.org, linux-mtd@lists.infradead.org,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org,
        open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-serial@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-mm@kvack.org, dccp@vger.kernel.org,
        linux-sctp@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Yuanhan Liu <yuanhan.liu@linux.intel.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20130108181645.GA7972@core.coreip.homeip.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Dmitry Torokhov <dmitry.torokhov@gmail.com> wrote:

>Hi Yuanhan,
>
>On Tue, Jan 08, 2013 at 10:57:53PM +0800, Yuanhan Liu wrote:
>> The current kfifo API take the kfifo size as input, while it rounds
>>  _down_ the size to power of 2 at __kfifo_alloc. This may introduce
>> potential issue.
>>=20
>> Take the code at drivers/hid/hid-logitech-dj.c as example:
>>=20
>> 	if (kfifo_alloc(&djrcv_dev->notif_fifo,
>>                        DJ_MAX_NUMBER_NOTIFICATIONS * sizeof(struct
>dj_report),
>>                        GFP_KERNEL)) {
>>=20
>> Where, DJ_MAX_NUMBER_NOTIFICATIONS is 8, and sizeo of(struct
>dj_report)
>> is 15.
>>=20
>> Which means it wants to allocate a kfifo buffer which can store 8
>> dj_report entries at once. The expected kfifo buffer size would be
>> 8 * 15 =3D 120 then. While, in the end, __kfifo_alloc will turn the
>> size to rounddown_power_of_2(120) =3D  64, and then allocate a buf
>> with 64 bytes, which I don't think this is the original author want.
>>=20
>> With the new log API, we can do like following:
>>=20
>> 	int kfifo_size_order =3D order_base_2(DJ_MAX_NUMBER_NOTIFICATIONS *
>> 					    sizeof(struct dj_report));
>>=20
>> 	if (kfifo_alloc(&djrcv_dev->notif_fifo, kfifo_size_order,
>GFP_KERNEL)) {
>>=20
>> This make sure we will allocate enough kfifo buffer for holding
>> DJ_MAX_NUMBER_NOTIFICATIONS dj_report entries.
>
>Why don't you simply change __kfifo_alloc to round the allocation up
>instead of down?
>
>Thanks.
>
>--=20
>Dmitry
>--
>To unsubscribe from this list: send the line "unsubscribe linux-media"
>in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi Dmitry,

I agree.   I don't see the benefit in pushing up the change to a kfifo in=
ternal decision/problem to many different places in the kernel.

Regards,
Andy

=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
