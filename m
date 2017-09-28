From: Yulia Kartseva <yulia.kartseva@gmail.com>
Subject: Re: [PATCH iproute2] tc: fix ipv6 filter selector attribute for some
 prefix lengths
Date: Wed, 27 Sep 2017 20:47:35 -0700
Message-ID: <CAOgqDSGvP_PmNEWfZ-+21hgP0Y1J7w+8Dne3x88Bfp9r9dcWmw@mail.gmail.com>
References: <CAOgqDSEvuZVExji=NXq0s1Ze9pQTawQGy=OQxLxwU7b52xHNXQ@mail.gmail.com>
 <20170927092634.0870468d@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="94eb2c128b32dc9f6e055a37c44d"
To: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:52510 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752343AbdI1Drh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 23:47:37 -0400
Received: by mail-qt0-f182.google.com with SMTP id o52so245957qtc.9
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 20:47:37 -0700 (PDT)
In-Reply-To: <20170927092634.0870468d@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c128b32dc9f6e055a37c44d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello Stephen,
Sending as an attachment.
Thank you!

On Wed, Sep 27, 2017 at 1:26 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 25 Sep 2017 11:12:38 -0700
> Yulia Kartseva <yulia.kartseva@gmail.com> wrote:
>
>> Wrong TCA_U32_SEL attribute packing if prefixLen AND 0x1f equals 0x1f.
>> These are  /31, /63, /95 and /127 prefix lengths.
>>
>> Example:
>> # tc filter add dev eth0 protocol ipv6 parent b: prio 2307 u32 match
>> ip6 dst face:b00f::/31
>> # tc filter show dev eth0
>> filter parent b: protocol ipv6 pref 2307 u32
>> filter parent b: protocol ipv6 pref 2307 u32 fh 800: ht divisor 1
>> filter parent b: protocol ipv6 pref 2307 u32 fh 800::800 order 2048
>> key ht 800 bkt 0
>>   match faceb00f/ffffffff at 24
>>
>>
>> The correct match would be "faceb00e/fffffffe": don't count the last
>> bit of the 4th byte as the network prefix. With fix:
>>
>> # tc filter show dev eth0
>> filter parent b: protocol ipv6 pref 2307 u32
>> filter parent b: protocol ipv6 pref 2307 u32 fh 800: ht divisor 1
>> filter parent b: protocol ipv6 pref 2307 u32 fh 800::800 order 2048
>> key ht 800 bkt 0
>>   match faceb00e/fffffffe at 24
>>
>>  tc/f_u32.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/tc/f_u32.c b/tc/f_u32.c
>> index 5815be9..14b9588 100644
>> --- a/tc/f_u32.c
>> +++ b/tc/f_u32.c
>> @@ -385,8 +385,7 @@ static int parse_ip6_addr(int *argc_p, char ***argv_=
p,
>>
>>   plen =3D addr.bitlen;
>>   for (i =3D 0; i < plen; i +=3D 32) {
>> - /* if (((i + 31) & ~0x1F) <=3D plen) { */
>> - if (i + 31 <=3D plen) {
>> + if (i + 31 < plen) {
>>   res =3D pack_key(sel, addr.data[i / 32],
>>         0xFFFFFFFF, off + 4 * (i / 32), offmask);
>>   if (res < 0)
>
> This patch looks correct, but will not apply cleanly because
> the mail system that you submitted it with is removing whitespace.
> If possible use a different client, or send as an attachment.
>



--=20
C =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=D0=BD=D0=B8=D0=B5=D0=BC, =D0=AE=D0=BB=D0=
=B8=D1=8F

--94eb2c128b32dc9f6e055a37c44d
Content-Type: application/octet-stream; name="f_u32.c.patch"
Content-Disposition: attachment; filename="f_u32.c.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j83wzpoz0

ZGlmZiAtLWdpdCBhL3RjL2ZfdTMyLmMgYi90Yy9mX3UzMi5jCmluZGV4IDQ3OWIzZjEuLmE4ZDA3
YjMgMTAwNjQ0Ci0tLSBhL3RjL2ZfdTMyLmMKKysrIGIvdGMvZl91MzIuYwpAQCAtMzgyLDggKzM4
Miw3IEBAIHN0YXRpYyBpbnQgcGFyc2VfaXA2X2FkZHIoaW50ICphcmdjX3AsIGNoYXIgKioqYXJn
dl9wLAogCiAJcGxlbiA9IGFkZHIuYml0bGVuOwogCWZvciAoaT0wOyBpPHBsZW47IGkrPTMyKSB7
Ci0vLwkJaWYgKCgoaSszMSkmfjB4MUYpPD1wbGVuKSB7Ci0JCWlmIChpICsgMzEgPD0gcGxlbikg
eworCQlpZiAoaSArIDMxIDwgcGxlbikgewogCQkJcmVzID0gcGFja19rZXkoc2VsLCBhZGRyLmRh
dGFbaS8zMl0sCiAJCQkJICAgICAgIDB4RkZGRkZGRkYsIG9mZis0KihpLzMyKSwgb2ZmbWFzayk7
CiAJCQlpZiAocmVzIDwgMCkK
--94eb2c128b32dc9f6e055a37c44d--
