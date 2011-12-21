From: "Anatoly Sivov" <mm05@mail.ru>
Subject: Re: tcp_mtu_probe implementation details
Date: Wed, 21 Dec 2011 13:50:30 +0400
Message-ID: <op.v6t2ygnyfzo5me@stalin>
References: <op.v6s5j2i0fzo5me@stalin>
 <CAGK4HS93u=3muZu_rkqK7FSacTHUytK5H6_dMNo_uOQY738R_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Vijay Subramanian" <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.mail.ru ([94.100.176.44]:54939 "EHLO smtp4.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652Ab1LUJud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 04:50:33 -0500
In-Reply-To: <CAGK4HS93u=3muZu_rkqK7FSacTHUytK5H6_dMNo_uOQY738R_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Vijay,

Thank you for your response.

>> The other question is about size_needed variable.
>> It is assigned to value probe_size + (tp->reordering + 1) *  
>> tp->mss_cache
>> And that is not clear for me.
>> What is this "(tp->reordering + 1) * tp->mss_cache" addition?
>>
>
> I think the idea is that you want enough bytes in the write_queue so
> that even if the probe is lost, the sender will get an ack even if
> there is reordering in the network. Without sufficient bytes, the
> probe will not be sent. This is what I make of the code but I could be
> wrong.

I believe, I found the explanation of this addition in RFC 4821:
   "TCP Fast Retransmit is not robust unless there are
    sufficient segments following a probe; that is, the sender SHOULD
    have enough data queued and sufficient receiver window to send the
    probe plus at least Tcprexmtthresh [RFC2760] additional segments."

However, I'm still confused with magic number 11 in "tp->snd_cwnd < 11"  
check.

Thanks.
