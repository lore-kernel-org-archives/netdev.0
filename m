From: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Wed, 4 May 2016 16:45:32 -0700
Message-ID: <CALAqxLXbMuK3Sj45vbf_r4GYQR=8bGUrhDz9-7+S2pbO_dJZ4A@mail.gmail.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
	<57286E15.2080900@mentor.com>
	<CAFGCpxx0f7g7rXyZ-P0EF7QVX7Z0ziK+7VMPKK7pQteBowkw3Q@mail.gmail.com>
	<5728837D.60702@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	YongQin Liu <yongqin.liu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ivan Vecera <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David B. Robins" <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org>
To: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5728837D.60702-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 3, 2016 at 3:54 AM, Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org> wrote:
> On 03/05/16 11:04, Guodong Xu wrote:
>>
>> did you test on ARM 64-bit system or ARM 32-bit? I ask because HiKey
>> is an ARM 64-bit system. I suggest we should be careful on that. I saw
>> similar issues when transferring to a 64-bit system in other net
>> drivers.
>
> We used 32-bit ARM and never tested on 64-bit ARM so I suggest that the
> commits need to be reviewed with 64-bit OS in mind.
>>
>>
>> Do you have any suggestion on this regard?
>
> Try testing on a Linux PC x86 32-bit OS which has has a kernel containing my
> ASIX commits. This will help to confirm whether the failure is related to
> 32-bit or 64-bit OS. Then try with Linux PC x86 64-bit OS, this should fail
> otherwise it points to something specific in your ARM 64-bit platform.

Just as a sample point, I have managed to reproduce exactly this issue
on an x86_64 system by simply scp'ing a large file.

[  417.819276] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  417.823415] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xef830347, offset 4
[  417.827502] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x31e2b348, offset 4
[  417.843779] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  417.847921] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x8af91035, offset 4
[  417.852004] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x8521fa03, offset 4
[  418.273394] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  418.277532] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x33cd9c7c, offset 4
[  418.281683] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x3d850896, offset 4
[  418.286227] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x86443357, offset 4
[  418.290319] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xee6c81d1, offset 4

I don't have any 32bit x86 installs around so I'm not sure I can easly
test there, but its clear its not arm64 specific.

thanks
-john
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
