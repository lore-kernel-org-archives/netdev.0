From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 16:04:20 -0700
Message-ID: <BANLkTin48HKVRn6kG8SCZNfhyWVVhkBArg@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com> <20110524142928.105d66ef@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:31837 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933354Ab1EXXEm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 19:04:42 -0400
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4ON4fXO026757
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:04:42 -0700
Received: from bwz15 (bwz15.prod.google.com [10.188.26.15])
	by hpaq3.eem.corp.google.com with ESMTP id p4ON4UIn026107
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:04:40 -0700
Received: by bwz15 with SMTP id 15so9326516bwz.33
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:04:40 -0700 (PDT)
In-Reply-To: <20110524142928.105d66ef@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 2:29 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 24 May 2011 11:52:42 -0700
> Mahesh Bandewar <maheshb@google.com> wrote:
>
>> Define macros to set/clear/test bits for feature set usage. This wil=
l eliminate
>> the direct use of these fields and enable future ease in managing th=
ese fields.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>> =A0include/linux/netdev_features.h | =A0137 ++++++++++++++++++++++++=
+++++++++++++++
>> =A0include/linux/netdevice.h =A0 =A0 =A0 | =A0 35 ++---------
>> =A02 files changed, 142 insertions(+), 30 deletions(-)
>> =A0create mode 100644 include/linux/netdev_features.h
>>
>> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_=
features.h
>> new file mode 100644
>> index 0000000..97bf8c4
>> --- /dev/null
>> +++ b/include/linux/netdev_features.h
>> @@ -0,0 +1,137 @@
>> +#ifndef =A0 =A0 =A0_NETDEV_FEATURES_H
>> +#define =A0 =A0 =A0_NETDEV_FEATURES_H
>> +
>> +/* Forward declarations */
>> +struct net_device;
>> +
>> +typedef =A0 =A0 =A0unsigned long *nd_feature_t
>
> typedef'ing a pointer is strongly discouraged by kernel coding style.
> You need to use another way such as open coding it.
>
The idea here is to have a typedef that we can use to avoid future
changes all over the code if we decide to change the way feature bits
are stored. So if this is bitmap it will be defined as "unsigned long
*" and if it were to be u64 then it's typedef-ed as "u64". So in one
case it's a pointer and in other case it's not! Now how do we handle
both these cases?

Thanks,
--mahesh..

> --
>
