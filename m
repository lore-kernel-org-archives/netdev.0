From: Quentin Monnet <quentin.monnet@netronome.com>
Subject: Re: [PATCH net-next 6/8] tools: bpftool: print all relevant byte
 opcodes for "load double word"
Date: Fri, 20 Oct 2017 16:50:04 +0100
Message-ID: <CAH3iqT5vPnOCEm6wjavbpSyC4Md922Bts3ynxxVCT-1=MWsgKA@mail.gmail.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
 <20171019224626.31608-7-jakub.kicinski@netronome.com> <063D6719AE5E284EB5DD2968C1650D6DD009D515@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:46762 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbdJTPuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 11:50:25 -0400
Received: by mail-qt0-f171.google.com with SMTP id 1so18995221qtn.3
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 08:50:25 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD009D515@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 20 October 2017 at 10:59, David Laight <David.Laight@aculab.com> wrote:
> From: Jakub Kicinski
>> Sent: 19 October 2017 23:46
>> The eBPF instruction permitting to load double words (8 bytes) into a
>> register need 8-byte long "immediate" field, and thus occupy twice the
>> space of other instructions. bpftool was aware of this and would
>> increment the instruction counter only once on meeting such instruction,
>> but it would only print the first four bytes of the immediate value to
>> load. Make it able to dump the whole 16 byte-long double instruction
>> instead (as would `llvm-objdump -d <program>`).
>
> Guess why most modern instruction sets use a 'load high' instruction
> to generate big constants...
>
> Interestingly, is there anything special in the rest of the
> second instruction in order to make it an identifiable no-op?

The remaining four bytes are taken from the "immediate" field of the second
instruction, which leaves the first four fields (offset, source and destina=
tion
registers, and in particular opcode) unused. As far as I know, these fields
remain at zero, and this makes it the only =E2=80=9Cinstruction=E2=80=9D to=
 have a null code
(although I am not sure this is a strict requirement, because I did not fin=
d
the code in the verifier that would reject a program having a non-null opco=
de
right after a "load double word immediate" instruction).

>

[=E2=80=A6]

> Why not just:
>         for (i =3D 0; i < len / sizeof(*insn); i +=3D 1 + double_insn) {
>
> ...
>
>         David
>

Yes, we could use that instead, although I am not sure this makes the code
more readable. So I do not believe this is worth a respin, tell me if you t=
hink
otherwise.

Thanks for the review!
Quentin
