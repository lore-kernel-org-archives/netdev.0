From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc 3/4] net-timestamp: tcp sockets return v6 errors on v6 sockets
Date: Tue, 25 Nov 2014 14:53:25 -0500
Message-ID: <CA+FuTScxGWU_AKgdYdfifUxRCvh=17xKoWLLvx3k_+t=NNezqg@mail.gmail.com>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
 <1416938286-14147-4-git-send-email-willemb@google.com> <20141125.134152.1265765328256853180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:58826 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaKYTx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:53:56 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so933354qab.30
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 11:53:56 -0800 (PST)
In-Reply-To: <20141125.134152.1265765328256853180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 1:41 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Tue, 25 Nov 2014 12:58:05 -0500
>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> TCP timestamping introduced MSG_ERRQUEUE handling for TCP sockets.
>> It always passed errorqueue requests onto ip_recv_error, but the
>> same tcp_recvmsg code may also be called for IPv6 sockets. In that
>> case, pass to ipv6_recv_error.
>>
>> Tested by asking for PKTINFO with
>>
>>   Documentation/networking/timestamping/txtimestamp -I
>>
>> Before this change, IPv6 sockets would return AF_INET/IP_PKTINFO
>> after the change, these sockets return AF_INET6/IPV6_PKTINFO
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> This looks like a bug fix to me, and is therefore probably 'net'
> material.

Okay. I'll submit it separately to net.
