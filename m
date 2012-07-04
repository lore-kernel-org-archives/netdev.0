From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 2/2] net: add support for NS8390 based eth controllers
 on some ColdFire CPU boards
Date: Wed, 4 Jul 2012 18:06:54 +1000
Message-ID: <4FF3F99E.30506@snapgear.com>
References: <1341377789-12970-1-git-send-email-gerg@snapgear.com> <1341377789-12970-3-git-send-email-gerg@snapgear.com> <1341379091.3627.15.camel@joe2Laptop> <4FF3E031.5040703@snapgear.com> <1341383999.3627.20.camel@joe2Laptop> <CAMuHMdVYiQyurOQOoeLbd6zXnaVK8Y9bUC=wXkHxhQO+cQwecQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	<netdev@vger.kernel.org>, <linux-m68k@vger.kernel.org>,
	Greg Ungerer <gerg@uclinux.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dnvwsmailout1.mcafee.com ([161.69.31.173]:44965 "EHLO
	DNVWSMAILOUT1.mcafee.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567Ab2GDIH5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 04:07:57 -0400
In-Reply-To: <CAMuHMdVYiQyurOQOoeLbd6zXnaVK8Y9bUC=wXkHxhQO+cQwecQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/2012 05:52 PM, Geert Uytterhoeven wrote:
> On Wed, Jul 4, 2012 at 8:39 AM, Joe Perches <joe@perches.com> wrote:
>>>>> +static int mcf8390_init(struct net_device *dev)
>>>>> +{
>>>>> +  static u32 offsets[] =3D {
>>>>> +          0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
>>>>> +          0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
>>>>> +  };
>>>>
>>>> const?  u8?
>>>
>>> That is assigned to the "reg_offset" field of "struct ei_device"
>>> (defined in the existing 8390.h) and that is:
>>>
>>>       u32 *reg_offset;         /* Register mapping table */
>>>
>>> So I can't change this.
>>
>> Sure you can, you can assign a u8 to a u32 just fine.
>
> It's not the value that's assigned, but a pointer to the table, so
> for now it must be non-const u32 *.
>
>> The value fits in a u8.  Might as well make it take
>> less data space.  static const makes it read-only and
>> makes the compiler assign it just once instead of at
>> function invocation.
>
> That needs changes to drivers/net/ethernet/8390/8390.h, and
> also probably to some drivers that assign values to the array.

Yes, that is right, some drivers as well.

Just making that local offsets array const generates compiler
warnings (as you would expect):

   CC      drivers/net/ethernet/8390/mcf8390.o
drivers/net/ethernet/8390/mcf8390.c: In function =91mcf8390_init=92:
drivers/net/ethernet/8390/mcf8390.c:393:23: warning: assignment discard=
s=20
qualifiers from pointer target type

Regards
Greg


-----------------------------------------------------------------------=
-
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.co=
m
SnapGear Group, McAfee                      PHONE:       +61 7 3435 288=
8
8 Gardner Close,                            FAX:         +61 7 3891 363=
0
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.co=
m
