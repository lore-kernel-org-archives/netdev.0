From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [SECURITY] [PATCH] Prevent crashing when parsing bad X.25 facilities
Date: Fri, 12 Nov 2010 10:53:36 +1100
Message-ID: <AANLkTik17Q68fOk=XGgyJqs5xLjfwNyepB3Fn0VH_FQC@mail.gmail.com>
References: <1289515414.5167.15.camel@dan>
	<AANLkTimL61V2wDvZcsM27ZHPUnEQqaqnk2MTb=E0nSCY@mail.gmail.com>
	<1289519342.5167.19.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42173 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744Ab0KKXxi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 18:53:38 -0500
Received: by fxm16 with SMTP id 16so1866281fxm.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 15:53:36 -0800 (PST)
In-Reply-To: <1289519342.5167.19.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, yes just remove them from the printk.

On Fri, Nov 12, 2010 at 10:49 AM, Dan Rosenberg
<drosenberg@vsecurity.com> wrote:
> I can take care of it. =A0Do you want me to just remove those items f=
rom
> the printk statement?
>
> -Dan
>
> On Fri, 2010-11-12 at 10:24 +1100, Andrew Hendry wrote:
>> Tested ok, although I noticed the CLASS_D default: message tries to
>> print the facility type, length and 4 values, while it may only have=
 2
>> values. Just needs p[4] and p[5] taken out. Do you want me to spin a
>> secondary patch or do you want to put them together?
>>
>> Acked-by: Andrew Hendry <andrew.hendry@gmail.com>
>>
>> On Fri, Nov 12, 2010 at 9:43 AM, Dan Rosenberg <drosenberg@vsecurity=
=2Ecom> wrote:
>> > Sorry I didn't catch this at the same time as my previous report s=
o it
>> > could be included in one patch.
>> >
>> > On parsing malformed X.25 facilities, decrementing the remaining l=
ength
>> > may cause it to underflow. =A0Since the length is an unsigned inte=
ger,
>> > this will result in the loop continuing until the kernel crashes.
>> >
>> > This patch adds checks to ensure decrementing the remaining length=
 does
>> > not cause it to wrap around.
>> >
>> > Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
>> > CC: stable <stable@kernel.org>
>> > ---
>> > =A0net/x25/x25_facilities.c | =A0 =A08 ++++++++
>> > =A01 files changed, 8 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
>> > index 3a8c4c4..bef8330 100644
>> > --- a/net/x25/x25_facilities.c
>> > +++ b/net/x25/x25_facilities.c
>> > @@ -61,6 +61,8 @@ int x25_parse_facilities(struct sk_buff *skb, st=
ruct x25_facilities *facilities,
>> > =A0 =A0 =A0 =A0while (len > 0) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (*p & X25_FAC_CLASS_MASK) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CLASS_A:
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len < 2)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retu=
rn 0;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (*p) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_REVERS=
E:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if(=
(p[1] & 0x81) =3D=3D 0x81) {
>> > @@ -104,6 +106,8 @@ int x25_parse_facilities(struct sk_buff *skb, =
struct x25_facilities *facilities,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len -=3D 2;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CLASS_B:
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len < 3)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retu=
rn 0;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (*p) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_PACKET=
_SIZE:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fac=
ilities->pacsize_in =A0=3D p[1];
>> > @@ -125,6 +129,8 @@ int x25_parse_facilities(struct sk_buff *skb, =
struct x25_facilities *facilities,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len -=3D 3;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CLASS_C:
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len < 4)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retu=
rn 0;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_DEBUG "=
X.25: unknown facility %02X, "
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "value=
s %02X, %02X, %02X\n",
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p[0], =
p[1], p[2], p[3]);
>> > @@ -132,6 +138,8 @@ int x25_parse_facilities(struct sk_buff *skb, =
struct x25_facilities *facilities,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len -=3D 4;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CLASS_D:
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len < p[1] + 2)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retu=
rn 0;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (*p) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_FAC_CALLIN=
G_AE:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if =
(p[1] > X25_MAX_DTE_FACIL_LEN || p[1] <=3D 1)
>> >
>> >
>> >
>
>
>
