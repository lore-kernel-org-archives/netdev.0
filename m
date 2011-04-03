From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: extending feature word.
Date: Sat, 2 Apr 2011 20:09:14 -0700
Message-ID: <BANLkTi=hCqT5BPe926N36omObpYvMcNtjg@mail.gmail.com>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
	<20110402124207.GB3147@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:52338 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757596Ab1DCDJV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 23:09:21 -0400
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p3339IfG026978
	for <netdev@vger.kernel.org>; Sat, 2 Apr 2011 20:09:19 -0700
Received: from wwb28 (wwb28.prod.google.com [10.241.241.92])
	by kpbe19.cbf.corp.google.com with ESMTP id p3339GKR024816
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 2 Apr 2011 20:09:17 -0700
Received: by wwb28 with SMTP id 28so4461479wwb.27
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2011 20:09:16 -0700 (PDT)
In-Reply-To: <20110402124207.GB3147@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 2, 2011 at 5:42 AM, Micha=C5=82 Miros=C5=82aw <mirq-linux@r=
ere.qmqm.pl> wrote:
> On Fri, Apr 01, 2011 at 07:07:05PM -0700, Mahesh Bandewar wrote:
>> Thanks for your comments on my loop-back patch. I was looking at the
>> code today from the perspective of extending various "features" for
>> word to an array of words and as Michael has pointed out, it's a hug=
e
>> change. So I'm thinking on the following lines
>> (include/linux/netdevice.h)
>>
>> +#define DEV_FEATURE_WORDS =C2=A0 =C2=A0 =C2=A02
>> +#define LEGACY_FEATURE_WORD =C2=A0 =C2=A00
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* currently active device features */
>> - =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 features;
>> + =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 features[DEV_FEATURE_WORDS];
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* user-changeable features */
>> - =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hw_features;
>> + =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hw_features[DEV_FEATURE_WORDS];
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* user-requested features */
>> - =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wanted_features;
>> + =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wanted_features[DEV_FEATURE_WORDS];
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* VLAN feature mask */
>> - =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vlan_features;
>> + =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vlan_features[DEV_FEATURE_WORDS];
>> +#define legacy_features =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0features[LEGACY_FEATURE_WORD]
>> +#define legacy_hw_features =C2=A0 =C2=A0 hw_features[LEGACY_FEATURE=
_WORD]
>> +#define legacy_wanted_features wanted_features[LEGACY_FEATURE_WORD]
>> +#define=C2=A0legacy_vlan_features =C2=A0 =C2=A0vlan_features[LEGACY=
_FEATURE_WORD]
>>
>>
>> So that it will be a matter of -
>>
>> s/features/legacy_features/
>> s/hw_features/legacy_hw_features/
>> s/wanted_features/legacy_wanted_features/
>> s/vlan_features/legacy_vlan_features/
>>
>> to start with as a first step. Once this is done, legacy_* can be
>> changed with respective arrays and modified as per the need. Comment=
s?
>
> You could just s/features/features[0]/ as well. Why the extra hiding?
>
I was thinking that features[0] is really a short term solution sine
there are only couple of bits left in this word and any new will have
to be added into the next word. So eventually it should be managed
properly at all these places where we'll replace it with features[0].
So it's a nice indication that this was the legacy way of dealing and
need to be altered for additional bits (especially where we see
legacy_* stuff) where ever required.

On the other hand replacing with features[0] breaks the NETDEVICE_SHOW
macro in net/core/net-sysfs.c and need to be expanded manually.

> If you want to split the work, it would be clearer to first convert
> hw_features and wanted_features (with all the core code touching it -
> this is the easy part), then vlan_features (this includes drivers'
> and VLAN code) and then features (it's all over).
>
I like the idea of splitting but it will be only useful when all of it
is done and not partially, isn't it? Or am I missing something?

> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>
