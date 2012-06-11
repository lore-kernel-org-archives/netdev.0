From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Mon, 11 Jun 2012 10:27:02 +0800
Message-ID: <CACVXFVPyfGq8=gAb-1wMk3zk15E=ys0mteVhHduGbQ8r6ajiHg@mail.gmail.com>
References: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
	<CACVXFVMwhoYyJHAsK0xF0poZxoZv8ENHhquPVAiGnsow5-FH8Q@mail.gmail.com>
	<CA+v9cxYvvRVWAUHX=b-P022pFbG1M7S=SZtOo2zfJnhAx5_+sQ@mail.gmail.com>
	<CACVXFVPj-4J2_UuOQ9NCW7wV_SLG50a-pEYqhd7K9sXuGmDmoQ@mail.gmail.com>
	<CA+v9cxbogzS7sVChqkRMgDUcs=aJgNDRH8ydoQ-_htfS2t52gQ@mail.gmail.com>
	<CACVXFVN0Y0p+WXUhJco6EKCdjx6Wg-guJLe79Bmj2K9KQGKToA@mail.gmail.com>
	<CA+v9cxZkWSeT_Qs+amOxRoW9Fmpgp6HY3Uj0dBGTOAqrbkQ5Hg@mail.gmail.com>
	<CACVXFVMGu2odRZdTRJo5_JDPMTMGWFy-NW+uLFnAqBO+3X=GJA@mail.gmail.com>
	<CA+v9cxZ6bDeNQ__tiPafiCau58dfvCgWmA1fbi_75uyySbtBAQ@mail.gmail.com>
	<CACVXFVPO+S5SPCzoyzCzjvh-wT4t2zh_naQ3GZ1B2fc9rmLJGw@mail.gmail.com>
	<CA+v9cxbd+PU--=o5T960fmOP1ZuxLc0+y1YgC_RLw-ivtZ8PRA@mail.gmail.com>
	<CACVXFVN4XB5V3N=CUpoN6Pcz7zVfQSoGQPQj508YnaueX1E3WA@mail.gmail.com>
	<CA+v9cxZd3W8BwWoxng0zPXe0-WA2pObre=Bjm4htJB_j-3YkJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
To: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+v9cxZd3W8BwWoxng0zPXe0-WA2pObre=Bjm4htJB_j-3YkJw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 10, 2012 at 7:13 PM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
> On Sun, Jun 10, 2012 at 5:53 PM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wro=
te:
>> On Sun, Jun 10, 2012 at 9:07 AM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
>>
>>>
>>> However, the other interface can work, it is of =A0"bInterfaceClass
>>> =A010 CDC Data". I can set IP to usb0 and it work fine.
>>>
>>> BTW, the device has 2 interfaces, one is of "bInterfaceClass =A0 =A0=
 =A0 =A010
>>> CDC Data" which includes bulk in/out endpoint for rx/tx; =A0the oth=
er is
>>> "bInterfaceClass =A0 =A0 =A0 =A0 2 Communications" which contains t=
he
>>> interrupt endpoint. From info dumped by "lsusb -v", the device is
>>> compliance with CDC protocol.
>>
>> Both the two interfaces belongs to cdc_ether device, see cdc spec
>> and usbnet_generic_cdc_bind(), which will make cdc_ether dirver to
>> claim data interface.
>>
>
> Yes, you are right.
>
>>>
>>>>>> BTW, the device can work well if I modprobe =A0cdc_ether driver =
after
>>>>>> changed the configuration.
>>>>
>>>> Maybe just the delay introduced by 'modprobe cdc_ether' fixes the
>>>> problem.
>>
>> If you can change the firmware, please find the bug and fix it. Othe=
rwise,
>> you can add a simple quirk in cdc_ether.c for your device.
>>
> Yes, this solution can solve the issue directly.
>
> However, =A0besides "-EPIPE", I think usbnet.c should also handle the
> error of "-EPROTO".

Yes, you can clear halt for -EPIPE, and take Alan's suggestion to
reset device if the error of "-EPROTO" is got.


Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
