From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [PATCH net-next v1 0/7] net: extend ethtool link mode bitmaps to
 48 bits
Date: Mon, 5 Jan 2015 10:16:35 -0800
Message-ID: <CAG88wWZMPNb+mw-T1DNgHn=n8MeimEDY+KJ15KGbvoZMuKeQBw@mail.gmail.com>
References: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
 <1420408540.5686.140.camel@decadent.org.uk> <CAHo-Ooxi8V_58b456vePY9_7ChuBe0jxEVHvGkGvRBpAR744yA@mail.gmail.com>
 <1420425003.5686.155.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Flavio Leitner <fbl@redhat.com>, Tom Gundersen <teg@jklm.no>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@emulex.com>,
	Govindarajulu Varadaraja
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:37495 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181AbbAESQ5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 13:16:57 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so20191192ier.0
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 10:16:56 -0800 (PST)
In-Reply-To: <1420425003.5686.155.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ben, I will send an updated version.

About rejecting high bits in drivers that don't support them: a basic
fix (in a separate patch series) could be something like follows in
ethtool_set_settings callbacks:  if (ecmd->advertising_hi) return
-EINVAL; with comments. But I don't find it very nice. Or: allocate a
new net_device::priv_flags bit and ask net/core/ethtool.c to accept
high advertising bits only when this flag is set? Any preference/other
options?

Related: lately, each new class of link modes declared =3D=3D 4 new bit=
s
allocated. At current pace these 16 new bits buy us only 4 new
classes, ie. a little more than 5 years if I extrapolate from the
recent past. Is the longer term plan to create a new ethtool ioctl
command specialized in link modes with variable length masks? Or to
switch to a brand new netlink interface altogether and take advantage
of that to revisit the link mode reporting/configuration with variable
length masks?

On Sun, Jan 4, 2015 at 6:30 PM, Ben Hutchings <ben@decadent.org.uk> wro=
te:
> On Mon, 2015-01-05 at 01:34 +0100, Maciej =C5=BBenczykowski wrote:
>> >> I can send updates to other drivers, even though it's rather poin=
tless
>> >> to update 1G drivers at this point for example. Please let me kno=
w,
>> >> but I'd prefer to do this in follow-up patches outside this first
>> >> patch series.
>> > [...]
>> >
>> > They should be changed to ensure they reject setting any of the hi=
gh
>> > advertising flags, but it's not urgent.
>>
>> if old drivers advertised a get/set_bits function while new drivers
>> advertised a get/set_new_bits function,
>> you could not updated any old drivers, and simply take care of
>> rejecting invalid bits in core, by calling set_new_bits if provided,
>> if not, rejecting bad bits and calling set_bits if no bad bits were
>> set.
>
> We've never checked that the reserved fields are zero before, and I
> think there are still drivers that don't fully validate the existing =
32
> bits.  So while I think drivers should fully validate the advertising
> flags, userland generally can't assume they do.  And therefore I don'=
t
> think it's worth adding complexity to the ethtool core that only part=
ly
> fixes this.
>
> Ben.
>
> --
> Ben Hutchings
> This sentence contradicts itself - no actually it doesn't.
