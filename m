From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc 1/4] net-timestamp: pull headers for SOCK_STREAM
Date: Tue, 25 Nov 2014 14:52:00 -0500
Message-ID: <CA+FuTSdT9=Hi7K3OnMxVRiK8PmS4=DvVqLumWx74OEz3okx23A@mail.gmail.com>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
 <1416938286-14147-2-git-send-email-willemb@google.com> <20141125.134240.861582393401487675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:38399 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbaKYTwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:52:31 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so919309qab.16
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 11:52:31 -0800 (PST)
In-Reply-To: <20141125.134240.861582393401487675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 1:42 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Tue, 25 Nov 2014 12:58:03 -0500
>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> When returning timestamped packets on the error queue, only return
>> the data that the application initially sent: not the protocol
>> headers.
>>
>> This changes the ABI. The TCP interface is new enough that it should
>> be safe to do so. The UDP interface could be changed analogously with
>>
>> +  else if (sk->sk_protocol == IPPROTO_UDP)
>> +    skb_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr));
>>
>> Tested with Documentation/networking/timestamping/txtimestamp -l 60 -x
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> What's the harm in exposing the headers?  Either it's harmful, and
> therefore doing so for UDP is bad too, or it's harmless and

Headers may expose information not available otherwise. I don't
immediately see critical problems, but that does not mean that they
might not lurk there.

We so far avoid exposing the sequence number, though keeping it hidden
is more about third parties. More in general, unprivileged processes
may start requesting timestamps only to learn tcp state that they
should either get from tcpinfo or cannot currently get at all, likely
for good reason. A far-fetched example is identifying admin iptables
tos mangling rules by reading the tos bits at the driver layer. At least
on my machine, iptables -L is privileged.

> we should probably leave it alone to not risk breaking anyone.

That's fair. I sent it for rfc first for that reason. I won't resubmit
unless more serious concerns are raised.
