From: Nuno Martins <nuno.martins@caixamagica.pt>
Subject: Re: [RFC PATCH 2/2] PID-based packet filtering support
Date: Thu, 5 Apr 2012 11:30:20 +0100
Message-ID: <CALKxAXUw1HU8Dqz8+DiCe_p-j3j0tV5=89sFaqLRLiQZA3BjUA@mail.gmail.com>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
	<19b9f7a0f38c1bab367da6f6cf622c8c2b3a4920.1333466900.git.nuno.martins@caixamagica.pt>
	<CAAsGZS6CoNuTBQ+YUjBc+Y9+oviHPrbrwGCCN0mZmTm5DCt8ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alfredo Matos <alfredo.matos@caixamagica.pt>,
	Paulo Trezentos <paulo.trezentos@caixamagica.pt>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62241 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753572Ab2DEKaW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 06:30:22 -0400
Received: by lahj13 with SMTP id j13so1334267lah.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 03:30:21 -0700 (PDT)
In-Reply-To: <CAAsGZS6CoNuTBQ+YUjBc+Y9+oviHPrbrwGCCN0mZmTm5DCt8ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 April 2012 19:57, chetan loke <loke.chetan@gmail.com> wrote:
> On Wed, Apr 4, 2012 at 5:16 AM, Nuno Martins
> <nuno.martins@caixamagica.pt> wrote:
>
>
>> +int get_local_packet_info_from_fd(unsigned int fd, struct packetInf=
o *ret)
>
> rename 'ret' to 'pi' or pkt_info or pick a name (must match the
> struct). And not just here but everywhere else.
>

Corrected.

>> +{
>> + =A0 =A0 =A0 struct file *f =3D fget(fd);
>> +
>> + =A0 =A0 =A0 if (f !=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(f);
>
> why not 'fput' after you return from 'get_local_packet_info_from_file=
' ?
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return get_local_packet_info_from_file=
(f, ret);
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 return -3;
>> +}
>> +

Yes, it make more sense to make the fput after I have done with the fil=
e.


>
>
>> +int get_local_packet_info_from_file(struct file *f, struct packetIn=
fo *ret)
>> +{
>> + =A0 =A0 =A0 struct socket *socket =3D NULL;
>> + =A0 =A0 =A0 short type;
>> + =A0 =A0 =A0 unsigned short family;
>> + =A0 =A0 =A0 int err =3D 0;
>> +
>> + =A0 =A0 =A0 if (f !=3D NULL) {
>
> This check is redundant because the
> caller(get_local_packet_info_from_fd) checks for NULL.

It's now corrected, it was there because in another function in
task_monitor in the beginning I was not checking for NULL.
So now the check for NULL in get_local_packet_info_from_file
is redundant, is going to be taken away.

>
> Move this function before get_local_packet_info_from_fd().
>
> re-arranged code looks like:
>
> int get_local_packet_info_from_file(...) {
> ....
> }
>
> int get_local_packet_info_from_fd(...) {
> =A0 ...
> =A0 ... get_local_packet_info_from_file(f, ret);
> =A0 ....
> }
>
>

Re-factored the code to look like that.

Thanks for you feedback, and all will be corrected on the next version =
and on
the repository.

> Chetan

Nuno Martins
