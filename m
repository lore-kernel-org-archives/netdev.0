From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] tcp: add TCP_CC_INFO socket option
Date: Wed, 29 Apr 2015 13:15:25 +0200
Message-ID: <5540BD4D.2070808@iogearbox.net>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>	 <1430263429-4069-3-git-send-email-edumazet@google.com>	 <55409393.3040003@iogearbox.net> <1430305625.3711.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35122 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422664AbbD2LPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 07:15:34 -0400
In-Reply-To: <1430305625.3711.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2015 01:07 PM, Eric Dumazet wrote:
> On Wed, 2015-04-29 at 10:17 +0200, Daniel Borkmann wrote:
>> On 04/29/2015 01:23 AM, Eric Dumazet wrote:
>>> Some Congestion Control modules can provide per flow information,
>>> but current way to get this information is to use netlink.
>>>
>>> Like TCP_INFO, let's add TCP_CC_INFO so that applications can
>>> issue a getsockopt() if they have a socket file descriptor,
>>> instead of playing complex netlink games.
>>>
>>> Sample usage would be :
>>>
>>>     union tcp_cc_info info;
>>>     socklen_t len = sizeof(info);
>>>
>>>     if (getsockopt(fd, SOL_TCP, TCP_CC_INFO, &info, &len) == -1)
>>>
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>> Cc: Yuchung Cheng <ycheng@google.com>
>>> Cc: Neal Cardwell <ncardwell@google.com>
>>
>> Presuming other cc algorithms would in future also export
>> internal information through this interface, would it make
>> sense to put tcp_cc_info into a container structure so we
>> don't miss out attr (vegas, dctcp, ...), like:
>>
>>     struct tcp_cc_exp {
>>       u32               kind;
>>       union tcp_cc_info info;
>>     };
>>
>> Otherwise looks good:
>>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> I thought of this, but I really believe this is not needed, as the
> application can already fetch CC name (if really its does not know yet)
>
> And I also wanted to get same layout for info provided by netlink and
> getsockopt()

Ok, I'm fine with that. Presumably, applications making use of
this facility would most likely set the cc op themselves from
the application, so they know exactly what to expect here. Or,
might have fetched it via the cc name albeit a bit inconvenient,
but not impossible.

Thanks,
Daniel
