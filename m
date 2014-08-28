From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v4 01/13] net: dsa: reduce number of protocol
 hooks
Date: Wed, 27 Aug 2014 18:49:34 -0700
Message-ID: <53FE8AAE.70405@gmail.com>
References: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>	<1409028581-17399-2-git-send-email-f.fainelli@gmail.com>	<53FDF879.1000504@intel.com> <20140827.162458.878869941352643208.davem@davemloft.net> <53FE6D2D.4060708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com, jhs@mojatatu.com
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59012 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309AbaH1Bte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 21:49:34 -0400
Received: by mail-pa0-f45.google.com with SMTP id bj1so415458pad.4
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 18:49:33 -0700 (PDT)
In-Reply-To: <53FE6D2D.4060708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2014 04:43 PM, Florian Fainelli wrote:
> On 08/27/2014 04:24 PM, David Miller wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>> Date: Wed, 27 Aug 2014 08:25:45 -0700
>>
>>> Just a thought, you might want to consider using a protocol value other
>>> than ETH_P_DSA.  Maybe we should add a new value named ETH_P_XDSA for
>>> this approach since what we are doing is a multiplexed DSA protocol now.
>>>
>>> This would allow for much easier back-porting of this if needed and also
>>> prevents us from possibly triggering any issues if there are any
>>> user-space APIs that might be trying to capture packets based on the
>>> protocol value.
>> Agreed, Florian can you respin this patch set using a newly allocated
>> ETH_P_* value for these new semantics?
> Absolutely. While at it, I just realized that ETH_P_BRCMTAG should
> probably remain within include/net/dsa.h. We don't want that to be
> exported to user-space since it is used for internal DSA de-multiplexing.
>
> Stay tuned!
> --
> Florian
>

Actually you could probably simplify this all a bit more by replacing
the ETH_P_BRCMTAG and tag_protcol values with a simple enum/u16 instead
of having to use be16 values.  It would make things a bit more explicit
as well since you could specify something like DSA_TAG_NONE = 0.

If you can't get to it I will probably work on submitting a patch for it
next week.

Thanks,

Alex
