From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Thu, 16 Jan 2014 09:28:49 +0800
Message-ID: <CACVXFVOGxWe5+o0hLROiPN43OCDekV2Ovz1yXr95H1m+yHGn4w@mail.gmail.com>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
	<1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com>
	<87ob3j1ocb.fsf@nemi.mork.no>
	<CAHNSM4KU8QEybpHgAcCjQoWuRjU8=wd1O7KUVMnrRJKQ-xr=Gg@mail.gmail.com>
	<87zjn3z6d5.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D458FEE@AcuExch.aculab.com>
	<87zjn086iz.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D45904D@AcuExch.aculab.com>
	<87vbxo83wp.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D4590AF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D4590AF-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 13, 2014 at 9:26 PM, David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> I believe all processing use the urb->num_sgs field to limit the number
>> of entries.  Common interfaces like dma_map_sg() and for_each_sg() limit
>> their processing to "nents" entries, and the USB code use the value of
>> urb->num_sgs for this parameter.
>
> Which mostly means that the sg_xxx functions are doing a whole load
> of unnecessary instructions and memory accesses...
>
> This probably has a lot to do with the significant difference in the
> cpu use for the usb3 and 'normal' ethernet interfaces.
>
> While each bit doesn't seem significant, they soon add up.

If you plan to remove the 'nents' parameter, I am wondering if it is
a good idea, because sg_nents() should be more heavy. Not mention
sometimes the callers just want to map/unmap part of entries.


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
