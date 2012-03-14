From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH 4/8] net/mlx4_en: Set max rate-limit for a TC
Date: Wed, 14 Mar 2012 12:31:15 +0200
Message-ID: <4F607373.7090001@mellanox.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com> <1331659323-12904-5-git-send-email-amirv@mellanox.com> <4F5F915E.4020505@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:40845 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760447Ab2CNKb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 06:31:27 -0400
In-Reply-To: <4F5F915E.4020505@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2012 08:26 PM, John Fastabend wrote:
> On 3/13/2012 10:21 AM, Amir Vadai wrote:
>> From: Amir Vadai<amirv@mellanox.co.il>
>>
>> Set max rate-limit using sysfs file /sys/class/net/<interface>/qos/ratelimit
>>
>> To set, enter a space separated list of values in units of 100Mbps.  For
>> example to set ratelimit of 5G to TC0 and 10G for the reset on eth2 issue:
>> echo 50 100 100 100 100 100 100 100 100>  /sys/class/net/eth2/qos/ratelimit
>>
>> Signed-off-by: Amir Vadai<amirv@mellanox.co.il>
>> ---
>>
>> We used sysfs since max bw isn't part of the ETS / DCBX NL support, and we're
>> open to other suggestions to add generic support for max bw, e.g add call to
>> the DCBX NL API.
>>
>
> Its not really part of DCB so adding it to DCBnl seems a bit forced. But how
> about adding it as an attribute of the mqprio which "knows" about the queue
> groupings?
See my answer below
>
> Does the rate limiter take into account the user priority to tc mapping or
> is it really just a group of queues with a rate limit? The code makes it
> look like it really is per 802.1Q traffic class.
This is true, the rate limiter is per 802.1Q traffic class, and the HW 
is using the UP to TC mapping when enforcing it.
That's why it can't be added to mqprio, which is a group of queues and 
not 802.1Q traffic class.
>
> .John

Thanks,
Amir
