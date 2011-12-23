From: "allan" <allan@asix.com.tw>
Subject: RE: [PATCH] drivers/net/usb/asix: fixed asix_get_wol reported wrong wol status issue
Date: Fri, 23 Dec 2011 14:41:11 +0800
Message-ID: <005101ccc13d$e0407bf0$a0c173d0$@com.tw>
References: <000c01ccc098$6b6c6690$424533b0$@com.tw> <CANEJEGuKdj4dEh2-kyWovPC1TBiBbEot7f6pDVnzLGCf==Oc5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"'Freddy Xin'" <freddy@asix.com.tw>,
	"'Eugene'" <elubarsky@gmail.com>,
	"=?utf-8?Q?'ASIX_Louis_=5B=E8=98=87=E5=A8=81=E9=99=B8=5D'?="
	<louis@asix.com.tw>
To: "'Grant Grundler'" <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEJEGuKdj4dEh2-kyWovPC1TBiBbEot7f6pDVnzLGCf==Oc5g@mail.gmail.com>
Content-Language: zh-tw
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Grant,

Thanks a lot for your great suggestions. I had re-submitted the driver =
patch again. Please correct me if there are anything I should improve o=
n the revised driver patch submission. Thanks a lot in advance.


---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
=46AX: 886-3-5799558
E-mail: allan@asix.com.tw=20
http://www.asix.com.tw/=20


-----Original Message-----
=46rom: grundler@google.com [mailto:grundler@google.com] On Behalf Of G=
rant Grundler
Sent: Friday, December 23, 2011 3:02 AM
To: ASIX Allan Email [office]
Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-kernel@vger.kern=
el.org; Freddy Xin; Eugene; ASIX Louis [=E8=98=87=E5=A8=81=E9=99=B8]
Subject: Re: [PATCH] drivers/net/usb/asix: fixed asix_get_wol reported =
wrong wol status issue

On Thu, Dec 22, 2011 at 2:56 AM, ASIX Allan Email [office]
<allan@asix.com.tw> wrote:
> Dear David,
>
> This is my first time to submit the driver patch onto Linux kernel ma=
inline source. Please correct me if anything is wrong on my submission =
way or email format. Thanks a lot for your great helps.

Hi Allan,
Thanks for submitting the patch.  I can advise as well since this
probably won't get applied due to how the email is "structured".

Your email which includes the patch needs to follow the "patch format"
described in Documentation/SubmittingPatches (see linux source tree).

Your email should have three main sections:
1) commit log entry + signed-off-by lines followed by one line with
"---" (and nothing else). This text summarizes *why* the patch is
needed: what bug it fixes or feature it enables.
2) optional comments/information about the testing of the patch (e.g.
"tested on Samsung Chromebook" or other comments that do NOT belong in
the commit log entry above. This section can be empty - not required.
3) "diff -u" format patch (this is what "git diff" will produce).

Do not append any other emails or additional text.

thanks!
grant

>
> =3D=3D=3D=3D=3D=3D=3D=3D
> Fixed the asix_get_wol() routine reported wrong wol status issue.
> This fix had been verified on x86 Linux kernel 3.0.0-12-generic syste=
m with AX88772A/AX88772/Belkin AX88178 USB dongles, and the wol functio=
n works fine (can be waked up by receiving the magic packets).
>
> Signed-off-by: Allan Chou <allan@asix.com.tw>
> Tested-by: Allan Chou <allan@asix.com.tw>
> ---
> diff --uprN a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
> --- a/drivers/net/usb/asix.c    2011-12-15 14:01:49.000000000 +0800
> +++ b/drivers/net/usb/asix.c    2011-12-22 18:20:39.000000000 +0800
> @@ -36,7 +36,7 @@
>  #include <linux/usb/usbnet.h>
>  #include <linux/slab.h>
>
> -#define DRIVER_VERSION "08-Nov-2011"
> +#define DRIVER_VERSION "22-Dec-2011"
>  #define DRIVER_NAME "asix"
>
>  /* ASIX AX8817X based USB 2.0 Ethernet Devices */
> @@ -689,6 +689,10 @@ asix_get_wol(struct net_device *net, str
>        }
>        wolinfo->supported =3D WAKE_PHY | WAKE_MAGIC;
>        wolinfo->wolopts =3D 0;
> +       if (opt & AX_MONITOR_LINK)
> +               wolinfo->wolopts |=3D WAKE_PHY;
> +       if (opt & AX_MONITOR_MAGIC)
> +               wolinfo->wolopts |=3D WAKE_MAGIC;
>  }
>
>  static int
>
>
> ---
> Best regards,
> Allan Chou
> Technical Support Division
> ASIX Electronics Corporation
> TEL: 886-3-5799500 ext.228
> FAX: 886-3-5799558
> E-mail: allan@asix.com.tw
> http://www.asix.com.tw/
>
>
> -----Original Message-----
> From: allan [mailto:allan@asix.com.tw]
> Sent: Saturday, December 17, 2011 10:36 AM
> To: 'Grant Grundler'
> Cc: 'Eugene'; 'netdev@vger.kernel.org'; 'Freddy Xin'; 'ASIX Louis [=E8=
=98=87=E5=A8=81=E9=99=B8]'
> Subject: RE: drivers/net/usb/asix: bug in asix_get_wol
>
> Dear Grant,
>
> I will double check this issue and submit the revised patch to Linux =
kernel mainline source next week. Thanks a lot for your great helps.
>
>
> ---
> Best regards,
> Allan Chou
> Technical Support Division
> ASIX Electronics Corporation
> TEL: 886-3-5799500 ext.228
> FAX: 886-3-5799558
> E-mail: allan@asix.com.tw
> http://www.asix.com.tw/
>
> -----Original Message-----
> From: grundler@google.com [mailto:grundler@google.com] On Behalf Of G=
rant Grundler
> Sent: Saturday, December 17, 2011 6:16 AM
> To: ASIX Allan Email [office]
> Cc: Eugene; netdev@vger.kernel.org; Freddy Xin; ASIX Louis [=E8=98=87=
=E5=A8=81=E9=99=B8]
> Subject: Re: drivers/net/usb/asix: bug in asix_get_wol
>
> On Thu, Dec 15, 2011 at 9:15 PM, ASIX Allan Email [office]
> <allan@asix.com.tw> wrote:
>> Resend without attachment due to below email server error.
> ...
>> -----Original Message-----
>> From: ASIX Allan Email [office] [mailto:allan@asix.com.tw]
>> Sent: Friday, December 16, 2011 11:38 AM
>> To: 'Grant Grundler'; 'Eugene'
>> Cc: 'netdev@vger.kernel.org'; 'Freddy Xin'; ASIX Louis [=E8=98=87=E5=
=A8=81=E9=99=B8]
>> Subject: RE: drivers/net/usb/asix: bug in asix_get_wol
>> Importance: High
>>
>> Dear Grant and Eugene,
>>
>> Please refer to the attached file and below statements to modify the
>> asix_get_wol() routine and let us know if this suggestion can solve
>> your issues or not? Thanks a lot.
>
> Allan,
> Thanks for the response but it doesn't answer my previous question.
> Let me ask the same question differently.
>
> Does WOL support in asix driver need more than the four lines of code=
?
> Ie does MONITOR_MODE need to be enabled or anything like that?
>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> static void
>> asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo=
)
>> {
>>        struct usbnet *dev =3D netdev_priv(net);
>>        u8 opt;
>>
>>        if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &op=
t) < 0) {
>>                wolinfo->supported =3D 0;
>>                wolinfo->wolopts =3D 0;
>>                return;
>>        }
>>        wolinfo->supported =3D WAKE_PHY | WAKE_MAGIC;
>>        wolinfo->wolopts =3D 0;
>>        if (opt & AX_MONITOR_LINK)
>>                wolinfo->wolopts |=3D WAKE_PHY;
>>        if (opt & AX_MONITOR_MAGIC)
>>                wolinfo->wolopts |=3D WAKE_MAGIC;
>> }
>
> This looks remarkably similar to the code Eugene said enables WOL for
> him (and it works). I not able to find any difference.
>
> If you believe it was a mistake to remove these four lines of code,
> please submit a patch (See Documentation/SubmittingPatches)  to add
> them back. You can add a "Tested-by: Eugene <elubarsky@gmail.com>"
> line after your own "Signed-off-by:" in the patch.
>
> thanks!
> grant
>
>
