From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: extending feature word.
Date: Tue, 5 Apr 2011 15:15:21 -0700
Message-ID: <BANLkTi=JH0R_T_sH4nYKeGRUA4GXt6Q5bQ@mail.gmail.com>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
	<20110402124207.GB3147@rere.qmqm.pl>
	<BANLkTi=hCqT5BPe926N36omObpYvMcNtjg@mail.gmail.com>
	<20110405113007.GA21358@rere.qmqm.pl>
	<1302005261.2932.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:52079 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab1DEWPY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 18:15:24 -0400
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p35MFMcG002221
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2011 15:15:22 -0700
Received: from bwz16 (bwz16.prod.google.com [10.188.26.16])
	by hpaq14.eem.corp.google.com with ESMTP id p35MF5Sn006494
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2011 15:15:21 -0700
Received: by bwz16 with SMTP id 16so752697bwz.4
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 15:15:21 -0700 (PDT)
In-Reply-To: <1302005261.2932.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 5, 2011 at 5:07 AM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Tue, 2011-04-05 at 13:30 +0200, Micha=C5=82 Miros=C5=82aw wrote:
>> On Sat, Apr 02, 2011 at 08:09:14PM -0700, Mahesh Bandewar wrote:
>> > On Sat, Apr 2, 2011 at 5:42 AM, Micha=C5=82 Miros=C5=82aw <mirq-li=
nux@rere.qmqm.pl> wrote:
>> > > On Fri, Apr 01, 2011 at 07:07:05PM -0700, Mahesh Bandewar wrote:
>> > > If you want to split the work, it would be clearer to first conv=
ert
>> > > hw_features and wanted_features (with all the core code touching=
 it -
>> > > this is the easy part), then vlan_features (this includes driver=
s'
>> > > and VLAN code) and then features (it's all over).
>> > I like the idea of splitting but it will be only useful when all o=
f it
>> > is done and not partially, isn't it? Or am I missing something?
>>
>> Since this is a big change, when split it might be easier to follow.
>> OTOH, with your idea of macro it might be easier to do incremental
>> changes (I think this will be a lot of work for no gain in this case=
).
>
> I strongly disagree with using macros for this. =C2=A0They are very l=
ikely to
> conflict with other identifiers..
>
> We might be able to get away with something like:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0union {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 features;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 feature[N]=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
> =C2=A0 =C2=A0 =C2=A0 =C2=A0union {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 vlan_featu=
res;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 vlan_featu=
re[N];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
> =C2=A0 =C2=A0 =C2=A0 =C2=A0union {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 hw_feature=
s;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 hw_feature=
[N];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
>
unfortunately the members have to be of the same size to be part of a
name-less union. Otherwise you have to name it and add a macro to
provide backward compatibility. I did not find other occurrence of
"legacy_(hw/wanted/vlan)_features" if that was your only concern.

Having a macro is not the best thing and ideally I would want this to
live as little as possible. Since the use is so wide spread, having
the ability to make incremental changes is required. Once we switch to
the new method, hopefully we can eliminate this macro.

> (assuming hw_features is new enough that there is no need for the
> alias).
>
> Anyway, if we're going to put all the feature words in net_device
> there's no longer any reason for NETIF_F_LOOPBACK not to be in the fi=
rst
> word.
>
Too late Ben, I think Tom already used the last available bit :)

> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
