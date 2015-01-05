From: Bas Peters <baspeters93@gmail.com>
Subject: Re: [PATCH] Drivers: isdn: gigaset: checkpatch cleanup
Date: Mon, 5 Jan 2015 13:34:23 +0100
Message-ID: <CAOgR63fxP0XzLBpn653oPYQhsdEJa+2+PqGGoXE=px6=UEuwJQ@mail.gmail.com>
References: <1420047298-7798-1-git-send-email-baspeters93@gmail.com>
	<54A80462.2030007@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hjlipp@web.de, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54A80462.2030007@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Tilman,

Thanks for the feedback. I made a lot of mistakes... Sorry for wasting =
your
time with this patch. I'll work on improving it and dividing it up
into smaller chunks
as recommended  by other kernel developers and will try to fix the issu=
es.

With kind regards,

Bas

2015-01-03 16:01 GMT+01:00 Tilman Schmidt <tilman@imap.cc>:
> [I only just noticed that my first reply got terribly mangled by my
> mailer, so here it is again, hopefully more readable this time.]
>
> Hello Bas,
>
> I have several objections to your patch.
>
> Am 31.12.2014 um 18:34 schrieb Bas Peters:
>> I have not been able to test the code as I do not have access to the
>> hardware but since no new features were really added I don't think t=
hat
>> should pose a problem.
>
> It's always problematic to change code you cannot test.
> At the very least, if you do coding style cleanups you should test
> whether the result still compiles and generates the same code as befo=
re.
>
>> --- a/drivers/isdn/gigaset/bas-gigaset.c
>> +++ b/drivers/isdn/gigaset/bas-gigaset.c
>> @@ -261,11 +261,12 @@ static inline void dump_urb(enum debuglevel le=
vel, const char *tag,
>>  {
>>  #ifdef CONFIG_GIGASET_DEBUG
>>       int i;
>> +
>>       gig_dbg(level, "%s urb(0x%08lx)->{", tag, (unsigned long) urb)=
;
>>       if (urb) {
>>               gig_dbg(level,
>> -                     "  dev=3D0x%08lx, pipe=3D%s:EP%d/DV%d:%s, "
>> -                     "hcpriv=3D0x%08lx, transfer_flags=3D0x%x,",
>> +                     "  dev=3D0x%08lx, pipe=3D%s:EP%d/DV%d:%s,
>> +                     hcpriv=3D0x%08lx, transfer_flags=3D0x%x,",
>
> This is syntactically wrong and won't compile. You cannot have an
> unescaped newline inside a string literal. (Applies to two later
> chunks, too.)
>
>> @@ -566,8 +566,8 @@ static int atread_submit(struct cardstate *cs, i=
nt timeout)
>>
>>       if (basstate & BS_SUSPEND) {
>>               dev_notice(cs->dev,
>> -                        "HD_READ_ATMESSAGE not submitted, "
>> -                        "suspend in progress\n");
>> +                        "HD_READ_ATMESSAGE not submitted,\
>> +                        suspend in progress\n");
>
> This makes the message less readable by inserting lots of whitespace
> after the comma. (Applies to five later chunks, too.)
>
>> @@ -2312,13 +2312,13 @@ static int gigaset_probe(struct usb_interfac=
e *interface,
>>       /* Reject application specific interfaces
>>        */
>>       if (hostif->desc.bInterfaceClass !=3D 255) {
>> -             dev_warn(&udev->dev, "%s: bInterfaceClass =3D=3D %d\n"=
,
>> +             dev_warn(&udev->dev, "%s: bInterfaceClass =3D=3D %d\n"=
,\
>>                        __func__, hostif->desc.bInterfaceClass);
>>               return -ENODEV;
>>       }
>>
>>       dev_info(&udev->dev,
>> -              "%s: Device matched (Vendor: 0x%x, Product: 0x%x)\n",
>> +              "%s: Device matched (Vendor: 0x%x, Product: 0x%x)\n",=
\
>>                __func__, le16_to_cpu(udev->descriptor.idVendor),
>>                le16_to_cpu(udev->descriptor.idProduct));
>
> This looks strange, and not like correct coding style. Why would you
> want to escape the end of line after a function argument?
>
>
>> --- a/drivers/isdn/gigaset/capi.c
>> +++ b/drivers/isdn/gigaset/capi.c
>
>> @@ -1370,7 +1373,7 @@ static void do_connect_req(struct gigaset_capi=
_ctr *iif,
>>       cmsg->adr.adrPLCI |=3D (bcs->channel + 1) << 8;
>>
>>       /* build command table */
>> -     commands =3D kzalloc(AT_NUM * (sizeof *commands), GFP_KERNEL);
>> +     commands =3D kzalloc(AT_NUM * (sizeof(*commands)), GFP_KERNEL)=
;
>
> Extra pair of parentheses around sizeof(*commands) is unnecessary.
> (Applies to one later chunk, too.)
>
>> --- a/drivers/isdn/gigaset/common.c
>> +++ b/drivers/isdn/gigaset/common.c
>> @@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, con=
st unsigned char *msg,
>>  {
>>       unsigned char outbuf[80];
>>       unsigned char c;
>> -     size_t space =3D sizeof outbuf - 1;
>> +     size_t space =3D sizeof(outbuf - 1);
>
> This is wrong. The sizeof operator must be applied to the array
> variable outbuf, not to the expression (outbuf - 1).
>
>> --- a/drivers/isdn/gigaset/ev-layer.c
>> +++ b/drivers/isdn/gigaset/ev-layer.c
>
>> @@ -1083,7 +1079,7 @@ static void do_action(int action, struct cards=
tate *cs,
>>
>>       int channel;
>>
>> -     unsigned char *s, *e;
>> +     unsigned char *s;
>>       int i;
>>       unsigned long val;
>>
>> @@ -1355,8 +1351,20 @@ static void do_action(int action, struct card=
state *cs,
>>               }
>>
>>               for (i =3D 0; i < 4; ++i) {
>> -                     val =3D simple_strtoul(s, (char **) &e, 10);
>> -                     if (val > INT_MAX || e =3D=3D s)
>> +                     unsigned long *e;
>> +
>> +                     val =3D kstrtoul(s, 10, e);
>> +                     if (val =3D=3D -EINVAL) {
>> +                             dev_err(cs->dev, "Parsing error on con=
verting string to\
>> +                                              unsigned long\n");
>> +                             break;
>> +                     }
>> +                     if (val =3D=3D -ERANGE) {
>> +                             dev_err(cs->dev, "Overflow error conve=
rting string to\
>> +                                              unsigned long\n");
>> +                             break;
>> +                     }
>> +                     if (val > INT_MAX || *e =3D=3D s)
>>                               break;
>>                       if (i =3D=3D 3) {
>>                               if (*e)
>> @@ -1364,7 +1372,7 @@ static void do_action(int action, struct cards=
tate *cs,
>>                       } else if (*e !=3D '.')
>>                               break;
>>                       else
>> -                             s =3D e + 1;
>> +                             s =3D *e + 1;
>>                       cs->fwver[i] =3D val;
>>               }
>>               if (i !=3D 4) {
>
> This cannot work. The pointer variable e gets dereferenced without
> ever being initialized. The type mismatches when declaring e as
> pointing to an unsigned long but comparing *e to s in one place and t=
o
> a character literal in another point make me wonder which semantics
> you had in mind for e in the first place.
> Also your error messages are not helpful for someone reading the log
> and trying to find out what went wrong, and not very readable because
> of the big stretch of whitespace you insert between the words "to" an=
d
> "unsigned". In fact I'm not even convinced it's a good idea to emit a
> log message at all here.
>
>> --- a/drivers/isdn/gigaset/gigaset.h
>> +++ b/drivers/isdn/gigaset/gigaset.h
>> @@ -94,8 +94,7 @@ enum debuglevel {
>>  #define gig_dbg(level, format, arg...)                             =
          \
>>       do {                                                          =
  \
>>               if (unlikely(((enum debuglevel)gigaset_debuglevel) & (=
level))) \
>> -                     printk(KERN_DEBUG KBUILD_MODNAME ": " format "=
\n", \
>> -                            ## arg);                               =
  \
>> +                     dev_dbg(cs->dev, KBUILD_MODNAME ": " format "\=
n")\
>>       } while (0)
>
> This will not work when
> - there is no cs variable in the context where the macro is used or
> - cs->dev doesn't contain a valid device pointer or
> - the format string references additional arguments,
> all of which actually occur in the driver.
>
>> --- a/drivers/isdn/gigaset/i4l.c
>> +++ b/drivers/isdn/gigaset/i4l.c
>
>> @@ -624,14 +624,14 @@ int gigaset_isdn_regdev(struct cardstate *cs, =
const char *isdnid)
>>  {
>>       isdn_if *iif;
>>
>> -     iif =3D kmalloc(sizeof *iif, GFP_KERNEL);
>> +     iif =3D kmalloc(sizeof(*iif, GFP_KERNEL));
>
> You're calling kmalloc with too few arguments here.
>
>>       if (!iif) {
>>               pr_err("out of memory\n");
>>               return -ENOMEM;
>>       }
>>
>> -     if (snprintf(iif->id, sizeof iif->id, "%s_%u", isdnid, cs->min=
or_index)
>> -         >=3D sizeof iif->id) {
>> +     if (snprintf(iif->id, sizeof(iif->id, "%s_%u", isdnid, cs->min=
or_index))
>> +         >=3D sizeof(iif->id)) {
>
> You're calling snprintf with too few arguments here.
>
>> --- a/drivers/isdn/gigaset/proc.c
>> +++ b/drivers/isdn/gigaset/proc.c
>> @@ -27,13 +27,18 @@ static ssize_t set_cidmode(struct device *dev, s=
truct device_attribute *attr,
>>                          const char *buf, size_t count)
>>  {
>>       struct cardstate *cs =3D dev_get_drvdata(dev);
>> -     long int value;
>> -     char *end;
>> +     long int *value;
>> +     int result;
>>
>> -     value =3D simple_strtol(buf, &end, 0);
>> -     while (*end)
>> -             if (!isspace(*end++))
>> -                     return -EINVAL;
>> +     result =3D kstrtol(buf, 0, &value);
>> +     if (result =3D=3D -ERANGE)
>> +             /* Overflow error */
>> +             dev_err(cs->dev, "Overflow error on conversion from st=
ring to\
>> +                              long\n");
>> +     if (result =3D=3D -EINVAL)
>> +             /* Parsing error  */
>> +             dev_err(cs->dev, "Parsing error on conversion from str=
ing to\
>> +                              long\n");
>>       if (value < 0 || value > 1)
>>               return -EINVAL;
>>
>
> This changes semantics. Your code will not accept the same input as
> the original code, and it will emit messages of its own instead of
> just returning an error code to the caller as it should.
>
> In sum: NACK.
>
> Regards,
> Tilman
>
> --
> Tilman Schmidt                              E-Mail: tilman@imap.cc
> Bonn, Germany
> Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
> Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
