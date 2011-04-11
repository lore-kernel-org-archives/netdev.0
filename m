From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: extending feature word.
Date: Mon, 11 Apr 2011 11:45:05 -0700
Message-ID: <BANLkTimFzTGKmhfRxzEUt_LwrnhAaetU5Q@mail.gmail.com>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
	<20110408100535.GB10565@rere.qmqm.pl>
	<BANLkTik4+P3GU+NzZ6JkKPgXhwip-+PM5w@mail.gmail.com>
	<20110410101954.GA23753@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:49553 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab1DKSpI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 14:45:08 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p3BIj783032367
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 11:45:07 -0700
Received: from bwz12 (bwz12.prod.google.com [10.188.26.12])
	by hpaq6.eem.corp.google.com with ESMTP id p3BIirFn001232
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 11:45:06 -0700
Received: by bwz12 with SMTP id 12so8926433bwz.27
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 11:45:06 -0700 (PDT)
In-Reply-To: <20110410101954.GA23753@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 10, 2011 at 3:19 AM, Micha=C5=82 Miros=C5=82aw
<mirq-linux@rere.qmqm.pl> wrote:
> On Fri, Apr 08, 2011 at 11:17:41AM -0700, Mahesh Bandewar wrote:
>> On Fri, Apr 8, 2011 at 3:05 AM, Micha=C5=82 Miros=C5=82aw <mirq-linu=
x@rere.qmqm.pl> wrote:
>> > On Fri, Apr 01, 2011 at 07:07:05PM -0700, Mahesh Bandewar wrote:
>> >> Thanks for your comments on my loop-back patch. I was looking at =
the
>> >> code today from the perspective of extending various "features" f=
or
>> >> word to an array of words and as Michael has pointed out, it's a =
huge
>> >> change. So I'm thinking on the following lines
>> >> (include/linux/netdevice.h)
>> >>
>> >> +#define DEV_FEATURE_WORDS =C2=A0 =C2=A0 =C2=A02
>> >> +#define LEGACY_FEATURE_WORD =C2=A0 =C2=A00
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* currently active device features */
>> >> - =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 features;
>> >> + =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 features[DEV_FEATURE_WORDS];
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* user-changeable features */
>> >> - =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hw_features;
>> >> + =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hw_features[DEV_FEATURE_WORDS];
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* user-requested features */
>> >> - =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wanted_features;
>> >> + =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wanted_features[DEV_FEATURE_WORDS];
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* VLAN feature mask */
>> >> - =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vlan_features;
>> >> + =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vlan_features[DEV_FEATURE_WORDS];
>> >
>> > Hmm. There might be no point in making features field an array.
>> > This gives us nothing really. Maybe just add features_2 or similar=
?
>> > If we ever get to the point there need to be more than two words f=
or
>> > features we can think of some abstraction layer then.
>> >
>> That is right! making it an array doesn't really buy us anything
>> unless there is a uniform way of managing all the bits spread across
>> multiple words inside that array. This was the reason why I have
>> changed that array into a bitmap in the patch that I have posted
>> earlier. This way the upper limit (currently only 32 bits) will be
>> removed and we'll have a long term solution. There will be little bi=
t
>> of work involved but 'doing-things-right' has cost associated.
>
> I really don't like the bitmap idea. It multiplies the amount of code
> needed to manipulate multiple bits at once --- and that's a common
> thing for drivers to do. Almost every driver that needs ndo_fix_featu=
res
> will clear sets --- checkumming set, TSO set, all TX offloads set, ..=
=2E
>
Should the added code be of any concern? If that is happening in the
control-path and does not affect the data-path as such; those added
instructions is a cost of added flexibility to we got through bitmap.
If performance is not at risk then that shouldn't be a problem.

> As a first step just add another set of words:
>
> union {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 features;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 features_2=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} /* anonymous struct */;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 features_array[2];
> } /* anonymous union */;
>
> This allows to change drivers after core supporting code gets impleme=
nted.
>
I agree that this will be an easier path as far as the extension of
features is concerned. Though this still does not simplify the
management of bits that are spanning across multiple words? Also
atomicity of those operations?

Thanks,
--mahesh..
