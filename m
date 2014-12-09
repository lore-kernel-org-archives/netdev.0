From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: wl1251: NVS firmware data
Date: Tue, 9 Dec 2014 08:48:28 +0800
Message-ID: <CACVXFVO+pX29UE53EDP4va0hoWQw8h0E9Ji9t3OL=e0FyERxyA@mail.gmail.com>
References: <201411271506.20457@pali>
	<CACVXFVPOLfDuqc0nLb-zM8vH618DLXy0xtZbUOn5_XvdxRZSDw@mail.gmail.com>
	<20141208163714.GA31169@kroah.com>
	<201412081747.30965@pali>
	<20141208205721.GA14895@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Grazvydas Ignotas <notasas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
	Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>,
	Sebastian Reichel <sre-GFxCN5SEZAc@public.gmane.org>,
	David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141208205721.GA14895-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 9, 2014 at 4:57 AM, Greg Kroah-Hartman
<gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
> On Mon, Dec 08, 2014 at 05:47:30PM +0100, Pali Roh=C3=A1r wrote:
>> On Monday 08 December 2014 17:37:14 Greg Kroah-Hartman wrote:
>> > On Mon, Dec 08, 2014 at 11:18:18PM +0800, Ming Lei wrote:
>> > > On Sat, Dec 6, 2014 at 9:02 PM, Pali Roh=C3=A1r
>> <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > > > On Saturday 06 December 2014 13:49:54 Pavel Machek wrote:
>> > > >  /**
>> > > >
>> > > > + * request_firmware_prefer_user: - prefer usermode helper
>> > > > for loading firmware + * @firmware_p: pointer to firmware
>> > > > image
>> > > > + * @name: name of firmware file
>> > > > + * @device: device for which firmware is being loaded
>> > > > + *
>> > > > + * This function works pretty much like
>> > > > request_firmware(), but it prefer + * usermode helper. If
>> > > > usermode helper fails then it fallback to direct access.
>> > > > + * Usefull for dynamic or model specific firmware data.
>> > > > + **/
>> > > > +int request_firmware_prefer_user(const struct firmware
>> > > > **firmware_p, +                           const char
>> > > > *name, struct device *device) +{
>> > > > +       int ret;
>> > > > +       __module_get(THIS_MODULE);
>> > > > +       ret =3D _request_firmware(firmware_p, name, device,
>> > > > +                               FW_OPT_UEVENT |
>> > > > FW_OPT_PREFER_USER); +       module_put(THIS_MODULE);
>> > > > +       return ret;
>> > > > +}
>> > > > +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
>> > >
>> > > I'd like to introduce request_firmware_user() which only
>> > > requests firmware from user space, and this way is simpler
>> > > and more flexible since we have request_firmware_direct()
>> > > already.
>> >
>> > Why would a driver care about what program provides the
>> > firmware?  It shouldn't at all, and we want to get rid of the
>> > userspace firmware loader, not encourage drivers to use it
>> > "exclusively" at all.
>> >
>>
>> Do not remove it! Without userspace firmware loader it is
>> impossible to load dynamic firmware files.
>
> You should not be loading "dynamic" firmware files with the firmware
> interface, as that's not a "firmware" file anymore, it's a "special
> binary file that my driver needs to be created and sent into the
> kernel."

It is reasonable to put firmware somewhere instead of default
search path, maybe in network.

>
> Use your own custom usermode helper for stuff like this, not the
> firmware interface.  But use a binary sysfs file if you want, that se=
ems
> to make sense for it...

It sounds like implementing an variant of request_firmware_user(), :-)

Thanks,
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
