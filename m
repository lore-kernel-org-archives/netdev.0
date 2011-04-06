From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 01/20] net-core: extending (hw_/wanted_/vlan_)features
 fields to a bitmap.
Date: Tue, 5 Apr 2011 18:35:26 -0700
Message-ID: <BANLkTimjYRiMCXEdHfaDaXAn+A0fgZR6ZQ@mail.gmail.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
	<1302050665-10460-2-git-send-email-maheshb@google.com>
	<1302053271.2935.152.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4793 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab1DFBf3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 21:35:29 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p361ZSqh009301
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2011 18:35:28 -0700
Received: from bwz16 (bwz16.prod.google.com [10.188.26.16])
	by wpaz24.hot.corp.google.com with ESMTP id p361ZQCI013694
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2011 18:35:27 -0700
Received: by bwz16 with SMTP id 16so1019735bwz.18
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 18:35:26 -0700 (PDT)
In-Reply-To: <1302053271.2935.152.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 5, 2011 at 6:27 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Tue, 2011-04-05 at 17:44 -0700, Mahesh Bandewar wrote:
>> Converting current use of (hw_/wanted_/vlan_)features to
>> legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed=
 usage.
> [...]
>> @@ -1029,44 +1065,51 @@ struct net_device {
>> =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0napi_list;
>> =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0unreg_list;
>>
>> +#define DEV_FEATURE_WORDS =A0 =A02
>> +#define =A0 =A0 =A0DEV_FEATURE_BITS =A0 =A0 =A0 =A0(DEV_FEATURE_WOR=
DS*sizeof(long)*BITS_PER_BYTE)
>> +#define LEGACY_FEATURE_WORD =A00
>> +
>> =A0 =A0 =A0 /* currently active device features */
>> - =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features;
>> + =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 features;
>> =A0 =A0 =A0 /* user-changeable features */
>> - =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_features;
>> + =A0 =A0 DECLARE_BITMAP(hw_feature, DEV_FEATURE_BITS);
> [...]
>
> Sorry, you can't get rid of hw_features without converting all the
> callers at the same time. =A0All code has to remain compilable after =
each
> single commit.
>
I thought I did! My "make allyesconfig; make all" went through. Did I
miss something?


> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
