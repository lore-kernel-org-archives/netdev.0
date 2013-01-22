From: Yauheni Kaliuta <yauheni@kaliuta.org>
Subject: Re: [PATCH net 2/3] net: cdc_mbim: send ZLP after max sized NTBs
Date: Tue, 22 Jan 2013 19:16:34 +0200
Message-ID: <CAAzmmD4ebn6p_xojieGkk5dzyVfhDizfcneUAUL=ZUzucH2nww@mail.gmail.com>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
	<1358783440-11459-3-git-send-email-bjorn@mork.no>
	<87wqv64gr9.fsf@home.kaliuta.org>
	<87hamab3fs.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	Oliver Neukum <oneukum@suse.de>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:50743 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512Ab3AVRQg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 12:16:36 -0500
In-Reply-To: <87hamab3fs.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Tue, Jan 22, 2013 at 12:01 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
> Yauheni Kaliuta <y.kaliuta@gmail.com> writes:
>>>>>>> "BM" =3D=3D Bj=C3=B8rn Mork writes:
>>
>>  > We normally avoid sending ZLPs by padding NTBs with a zero byte
>>  > if the NTB is shorter than dwNtbOutMaxSize, resulting in a short
>>  > USB packet instead of a ZLP.  But in the case where the NTB lengt=
h
>>  > is exactly dwNtbOutMaxSize and this is an exact multiplum of
>>  > wMaxPacketSize, then we must send a ZLP.
>>
>> The idea of NCM was to avoid extra ZLPs. If your transfer is exactly
>> dwNtbOutMaxSize, it's known, you can submit such request on the rece=
iver
>> side and you do not need any EOT indicatation, so the frametime can =
be
>> used for useful data.
>
> Yes, that makes sense.  And I understand that both you and Alexey are=
 of
> this opinion.
>
> But this idea is by no means made clear (to me) in the spec.  I do no=
t
> think the current wording is precise enough to expect every implement=
or
> to understand any such intent.  The only place I find either "short
> packet" or ZLP mentioned in the NCM spec is in tables 3-1 and 3-2,
> describing the 16bit and 32bit NTH formats, in the description of the
> (d)wBlockLength fields.  And even there it is only mentioned in the
> context of the special (d)wBlockLength =3D 0x0000 handling.

I agree, it could be a bit unclear,

"
If exactly dwNtbInMaxSize or dwNtbOutMaxSize
bytes are sent, and the size is a multiple of wMax-
PacketSize for the given pipe, then no ZLP shall be
sent.
"
is an independent clause.

>
> If the intent was to prevent ZLPs, then it would have been wise to wr=
ite
> that in the NCM standard. As it stands you have to use a lot of
> imagination to read that intent into the current spec.

Well, I hope the guys took your complains into account and will fix
the wording in the future spec versions.
