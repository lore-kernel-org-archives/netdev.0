From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Mon, 13 Jan 2014 13:25:26 +0100
Message-ID: <87vbxo83wp.fsf@nemi.mork.no>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
	<1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com>
	<87ob3j1ocb.fsf@nemi.mork.no>
	<CAHNSM4KU8QEybpHgAcCjQoWuRjU8=wd1O7KUVMnrRJKQ-xr=Gg@mail.gmail.com>
	<87zjn3z6d5.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D458FEE@AcuExch.aculab.com>
	<87zjn086iz.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D45904D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D45904D-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
	(David Laight's message of "Mon, 13 Jan 2014 11:52:04 +0000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org> writes:
> From: Bj=C3=B8rn Mork
>> David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org> writes:
>>=20
>> > The patch you submitted is wrong.
>> > Whoever wrote the sg interface was on crack.
>> > The 'last' marker needs moving as well.
>>=20
>> I'm afraid I don't understand what you meant by this.
>>=20
>> sg_init_table() set the 'last' marker.  AFAICS, you don't need to ch=
ange
>> it unless you want to chain lists.
>>=20
>> Care to explain with some code?
>
> Just assuming that there will be some code, somewhere, that will try
> to process the entire sg list - so won't like the entry with a
> NULL pointer and zero length at the end.
>
> If all the places that process the list are given an explicit
> number of entries, or don't care about the NULL it doesn't matter.

I believe all processing use the urb->num_sgs field to limit the number
of entries.  Common interfaces like dma_map_sg() and for_each_sg() limi=
t
their processing to "nents" entries, and the USB code use the value of
urb->num_sgs for this parameter.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
