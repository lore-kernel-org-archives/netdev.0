From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 7/7] vxlan: allow setting ipv6 traffic class
Date: Wed, 16 Mar 2016 13:52:05 +0100
Message-ID: <56E956F5.6010500@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>	<c50f1e302411f7e4fe73ec469e0683f3e14fe830.1457099834.git.daniel@iogearbox.net> <20160316115952.463e851c@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52377 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933804AbcCPMwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 08:52:11 -0400
In-Reply-To: <20160316115952.463e851c@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 11:59 AM, Jiri Benc wrote:
[...]
>> @@ -1807,6 +1809,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
>>
>>   	memset(&fl6, 0, sizeof(fl6));
>>   	fl6.flowi6_oif = oif;
>> +	fl6.flowi6_tos = RT_TOS(tos);
>
> Nothing against this but the reason it was missing was that it's never
> used. Unless I'm missing something the IPv6 code does not use this
> field at all for lookups.
>
> This patch is not wrong but it's effectively dead code right now.
> I'll be happy to be proven wrong, though.

Hmm, you're right, thanks for pointing this out! Guess I shouldn't have
judged from geneve_get_v6_dst(), where this seems wrong as well ... If
noone is faster than me, I can make a patch removing these from both,
vxlan and geneve for the route lookup itself. Maybe the flowi6_tos define
should just be removed in general for the time being until there's real
support.

> (Sorry for answering after such long time, I'm catching up after a
> vacation.)
>
>   Jiri
>
