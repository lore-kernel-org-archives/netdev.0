From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 13:05:10 +0200
Message-ID: <1295ed070903120405y350cb5b3uefb88518c24e87a8@mail.gmail.com>
References: <1236772642-12705-1-git-send-email-pktoss@gmail.com>
	 <200903121759.31024.rusty@rustcorp.com.au>
	 <1295ed070903120044s63b4da71i68add51703952d0f@mail.gmail.com>
	 <200903121946.24847.rusty@rustcorp.com.au>
	 <1295ed070903120323y21c9b3ddrf382ba765d060e65@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:38670 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbZCLLFN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 07:05:13 -0400
Received: by ewy25 with SMTP id 25so313194ewy.37
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 04:05:10 -0700 (PDT)
In-Reply-To: <1295ed070903120323y21c9b3ddrf382ba765d060e65@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 12:23 PM, Pantelis Koukousoulas
<pktoss@gmail.com> wrote:
>> No, that's absolutely sane behavior, the previous was buggy. =A0If a=
 network
>> doesn't support carrier, you shouldn't look for it.
>>
>> Since they've fixed this in Network Manager, I'm not tempted to lie =
about it
>> in the driver (though the distributions might choose to).
>>
>> Rusty.
>>
>
> Ok, if "lying" is reporting that the driver supports carrier
> detection, this looks
> like an innocent lie :). Because the carrier *is* on, this is the tru=
th and you
> could just as well claim that the virtual hardware supports detection
> as that it doesn't :)

After reading this one more time, it doesn't make much sense, so let me=
 try
to explain my point of view more clearly:
=46or the wired case, carrier status =3D=3D "is cable connected?"
(NetworkManager is asking that)

So,

* virtio saying "Hey, I have no idea if cable is connected or not. I
have no way to know that".
  (aka carrier detect not supported)

I think this is closer to lying than:

* "Hey, I know that the cable is connected". =3D=3D carrier detection
supported. carrier is on

Because unlike prehistoric hardware / incomplete drivers, virtio *does*=
 know :)

Even if someone comes up with a patch at the hypervisor / emulator
level that allows
the user to set carrier status to on or off, then pressure should be
applied on them
to implement this change in a way that makes this known to the virtio_n=
et driver
for the same reasons that actual hardware does it (i.e., users like / w=
ant this
functionality :)

Hope this is clearer,
Pantelis
