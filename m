From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 4/4] u32: use get_unaligned_be32
Date: Tue, 3 Aug 2010 07:01:13 +0800
Message-ID: <AANLkTimHwS1-TGdRVf8qt0qE_gOvLZOaHGiHDN=QwSNH@mail.gmail.com>
References: <20100802220030.991706005@vyatta.com> <20100802220113.821018357@vyatta.com>
	<AANLkTimNBA4E0-iX6fesYPch-N1TDgg2kD0r-tK5Mq7A@mail.gmail.com>
	<20100802154505.46cfe94a@nehalam> <1280789717.5914.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61673 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551Ab0HBXBk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:01:40 -0400
Received: by wwj40 with SMTP id 40so4483974wwj.1
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 16:01:34 -0700 (PDT)
In-Reply-To: <1280789717.5914.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 3, 2010 at 6:55 AM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Mon, 2010-08-02 at 15:45 -0700, Stephen Hemminger wrote:
>> On Tue, 3 Aug 2010 06:34:59 +0800
>> Changli Gao <xiaosuo@gmail.com> wrote:
>>
>> > On Tue, Aug 3, 2010 at 6:00 AM, Stephen Hemminger <shemminger@vyat=
ta.com> wrote:
>> > > U32 classifier reads data from packet at a offset passed in from
>> > > user space. The offset should be aligned, but it is unsafe pract=
ice
>> > > to depend on values from userspace.
>> > >
>> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> > >
>> > > --- a/net/sched/cls_u32.c =A0 =A0 =A0 2010-08-01 11:21:06.945820=
852 -0700
>> > > +++ b/net/sched/cls_u32.c =A0 =A0 =A0 2010-08-01 11:24:55.257793=
848 -0700
>> > > @@ -41,6 +41,7 @@
>> > > =A0#include <net/netlink.h>
>> > > =A0#include <net/act_api.h>
>> > > =A0#include <net/pkt_cls.h>
>> > > +#include <asm/unaligned.h>
>> > >
>> > > =A0struct tc_u_knode
>> > > =A0{
>> > > @@ -140,7 +141,7 @@ next_knode:
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data =3D skb_head=
er_pointer(skb, toff, 4, &_data);
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!data)
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0g=
oto out;
>> > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((*data ^ key->=
val) & key->mask) {
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((get_unaligned=
_be32(data) ^ key->val) & key->mask) {
>> >
>> > be32()? I think it may break configuration.
>>
>> The data pointer is be32 * already.
>
> But get_unaligned_be32() converts to native byte order.
>

__be32 does't mean the dereferenced data will be converted to be32. It
is just a notation.

typedef __u16 __bitwise __le16;
typedef __u16 __bitwise __be16;
typedef __u32 __bitwise __le32;
typedef __u32 __bitwise __be32;
typedef __u64 __bitwise __le64;
typedef __u64 __bitwise __be64;

__be* is defined the same as __le*. The compiler can't get any endian i=
nfo.

Here is the discussion about http://kerneltrap.org/node/3848

Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
