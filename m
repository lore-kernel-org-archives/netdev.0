From: Derek Ditch <derek.ditch@gmail.com>
Subject: Re: [Bug 120441] af_packet no longer uses symmetric hashing
Date: Thu, 16 Jun 2016 09:40:25 -0500
Message-ID: <C904C669-AE19-4514-99C8-6B9E9838B206@gmail.com>
References: <511F6A17-BD35-4846-A717-1463B74D7F2A@gmail.com> <5762B9C0.9010902@iogearbox.net>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tom@herbertland.com, jiri@resnulli.us,
	willemb@google.com, eric@regit.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33105 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038AbcFPOkc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:40:32 -0400
Received: by mail-oi0-f65.google.com with SMTP id e205so8470550oig.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 07:40:32 -0700 (PDT)
In-Reply-To: <5762B9C0.9010902@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 16Jun 2016, at 09:37, Daniel Borkmann <daniel@iogearbox.net> wrote=
:
>=20
> On 06/16/2016 03:57 PM, Derek Ditch wrote:
> [...]
>>> Begin forwarded message:
>>>=20
>>> From: bugzilla-daemon@bugzilla.kernel.org
>>> Subject: [Bug 120441] af_packet no longer uses symmetric hashing
>>> Date: June 16, 2016 at 07:35:54 -0500
>>> To: derek.ditch@gmail.com
>>>=20
>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D120441
>=20
> Just thinking out loud, perhaps one way would be to implement your ow=
n fanout
> hashing via eBPF demuxer, f.e. in case CPU selection etc wouldn't wor=
k. Another
> option could be to have a (2nd) customizable hash demux that would en=
force to
> always go through the flow-dissector and where you would have a socke=
t option
> to control keys for it, but I presume that seems rather less desirabl=
e.

It=E2=80=99s less desirable, but at the moment seems like the path of l=
east resistance. I haven=E2=80=99t written an eBPF program before, so I=
=E2=80=99m reading up on that. Once I get that worked out I can add tha=
t to the socket. Have you implemented this in netsniff-ng or something =
else yet, Daniel?

=E2=80=94
Derek Ditch
derek.ditch@gmail.com
GPG: 0x2543A3B5
>=20
>>> --- Comment #2 from Eric Leblond <eric@regit.org> ---
>>> This patch has been introduced in 4.2.
>>>=20
>>> --
>>> You are receiving this mail because:
>>> You reported the bug.
>>> Begin forwarded message:
>>>=20
>>> From: bugzilla-daemon@bugzilla.kernel.org
>>> Subject: [Bug 120441] af_packet no longer uses symmetric hashing
>>> Date: June 16, 2016 at 06:59:58 -0500
>>> To: derek.ditch@gmail.com
>>>=20
>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D120441
>>>=20
>>> Eric Leblond <eric@regit.org> changed:
>>>=20
>>>           What    |Removed                     |Added
>>> -------------------------------------------------------------------=
---------
>>>                 CC|                            |eric@regit.org
>>>=20
>>> --- Comment #1 from Eric Leblond <eric@regit.org> ---
>>> It seems the problem has been introduced by
>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/com=
mit/?id=3D42aecaa9bb2bd57eb8d61b4565cee5d3640863fb
>>> where the symetrical jhash_3words function has been replaced by jha=
sh2.
>>>=20
>>> --
>>> You are receiving this mail because:
>>> You reported the bug.
>>=20
>>=20
>=20
