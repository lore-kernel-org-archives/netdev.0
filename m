From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 3/3] geneve: Remote Checksum Offload support
Date: Tue, 8 Dec 2015 11:59:45 -0800
Message-ID: <CALx6S36dU-RLUSTTZz8dVZHD7=p3=modbjUOePKMYG96FrA_zA@mail.gmail.com>
References: <1449599238-4094072-1-git-send-email-tom@herbertland.com>
	<1449599238-4094072-4-git-send-email-tom@herbertland.com>
	<20151208193150.GH3598@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Kernel Team <kernel-team@fb.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35167 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbbLHT7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 14:59:46 -0500
Received: by ioc74 with SMTP id 74so35798750ioc.2
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 11:59:45 -0800 (PST)
In-Reply-To: <20151208193150.GH3598@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 11:31 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Tue, Dec 08, 2015 at 10:27:18AM -0800, Tom Herbert wrote:
>> Add support for remote checksum offload in both the normal and GRO
>> paths. netlink command are used to enable sending of the Remote
>> Checksum Data, and allow processing of it on receive. The Remote
>
Extraneous.

> afsO&^(*&5^a+++NO CARRIER
>
> Did you mean to finish that sentence? ;-)
>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>
> Jesse is going to have to comment on your (ab)use of the reserved
> fields.  I presume that an RFC would be forthcoming?
>
I'll spin an I-D once there is agreement on the approach. This is
identical to VXLAN excepted the bit flag indicating csum_start is
present might be different.

https://tools.ietf.org/html/draft-herbert-vxlan-rco-00


>> diff --git a/include/net/geneve.h b/include/net/geneve.h
>> index 3106ed6..b59ad0a 100644
>> --- a/include/net/geneve.h
>> +++ b/include/net/geneve.h
>> @@ -8,9 +8,9 @@
>>
>>  /* Geneve Header:
>>   *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> - *  |Ver|  Opt Len  |O|C|    Rsvd.  |          Protocol Type        |
>> + *  |Ver|  Opt Len  |O|C|X|  Rsvd.  |          Protocol Type        |
>>   *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> - *  |        Virtual Network Identifier (VNI)       |    Reserved   |
>> + *  |        Virtual Network Identifier (VNI)       |U| Csum start  |
>>   *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>>   *  |                    Variable Length Options                    |
>>   *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>
> Otherwise, LGTM -- I'm really happy to see Geneve get this attention!
>
> Acked-by: John W. Linville <linville@tuxdriver.com>
>
> --
> John W. Linville                Someday the world will need a hero, and you
> linville@tuxdriver.com                  might be all we have.  Be ready.
