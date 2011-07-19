From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: Re: [PATCH] slcan: remove unused 'leased', 'line' and 'pid' fields
 from the 'slcan' structure
Date: Tue, 19 Jul 2011 21:18:33 +0400
Message-ID: <CAKh5naZ+ZfiizTp7zw_m8MjbdC04gQcfUZCE3pKH5ZcDr5Os9A@mail.gmail.com>
References: <CAKh5naa=x13=wUE+MLAYv0XQ4OhuY5G47ZDmFz0vbkibNtoz-A@mail.gmail.com>
 <4E25A267.4030005@hartkopp.net>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:44644 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab1GSRSy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 13:18:54 -0400
Received: by qyk29 with SMTP id 29so2192245qyk.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 10:18:53 -0700 (PDT)
In-Reply-To: <4E25A267.4030005@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, it seems that it is.

2011/7/19 Oliver Hartkopp <socketcan@hartkopp.net>:
> On 19.07.2011 09:58, Matvejchikov Ilya wrote:
>> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
>> ---
>
> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
>
> Thanks Ilya!
>
> Your cleanup is obviously fixing some fallout from this patch
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D5342b77c4123ba39f911d92a813295fb3bb21f69
>
> which emerged in 2.6.32 for slip.c .
>
> Best regards,
> Oliver
>
>
>> =A0drivers/net/can/slcan.c | =A0 10 +---------
>> =A01 files changed, 1 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
>> index 1b49df6..805ee29 100644
>> --- a/drivers/net/can/slcan.c
>> +++ b/drivers/net/can/slcan.c
>> @@ -95,10 +95,6 @@ struct slcan {
>> =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 flags; =A0 =A0 =A0 =A0=
 =A0/* Flag values/ mode etc =A0 =A0 */
>> =A0#define SLF_INUSE =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /* Channel in use =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0#define SLF_ERROR =A0 =A0 =A0 =A0 =A0 =A01 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /* Parity, etc. error =A0 =A0 =A0 =A0*/
>> -
>> - =A0 =A0 unsigned char =A0 =A0 =A0 =A0 =A0 leased;
>> - =A0 =A0 dev_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 line;
>> - =A0 =A0 pid_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid;
>> =A0};
>>
>> =A0static struct net_device **slcan_devs;
>> @@ -462,7 +458,7 @@ static void slc_sync(void)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sl =3D netdev_priv(dev);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (sl->tty || sl->leased)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (sl->tty)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dev->flags & IFF_UP)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_close(dev);
>> @@ -565,8 +561,6 @@ static int slcan_open(struct tty_struct *tty)
>>
>> =A0 =A0 =A0 sl->tty =3D tty;
>> =A0 =A0 =A0 tty->disc_data =3D sl;
>> - =A0 =A0 sl->line =3D tty_devnum(tty);
>> - =A0 =A0 sl->pid =3D current->pid;
>>
>> =A0 =A0 =A0 if (!test_bit(SLF_INUSE, &sl->flags)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Perform the low-level SLCAN initializ=
ation. */
>> @@ -617,8 +611,6 @@ static void slcan_close(struct tty_struct *tty)
>>
>> =A0 =A0 =A0 tty->disc_data =3D NULL;
>> =A0 =A0 =A0 sl->tty =3D NULL;
>> - =A0 =A0 if (!sl->leased)
>> - =A0 =A0 =A0 =A0 =A0 =A0 sl->line =3D 0;
>>
>> =A0 =A0 =A0 /* Flush network side */
>> =A0 =A0 =A0 unregister_netdev(sl->dev);
>
>
