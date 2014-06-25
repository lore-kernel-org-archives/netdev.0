From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 3/7] net-timestamp: tx timestamp without payload
Date: Wed, 25 Jun 2014 17:22:09 -0400
Message-ID: <CA+FuTSfDwwdLdbegUup_gQzzBeu=os9fQKnJH8+CHfEPFcDkhA@mail.gmail.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
 <1403624632-17327-4-git-send-email-willemb@google.com> <20140625051648.GE3845@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:56773 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846AbaFYVWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 17:22:40 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so2338235qcx.13
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:22:39 -0700 (PDT)
In-Reply-To: <20140625051648.GE3845@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 1:16 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Tue, Jun 24, 2014 at 11:43:48AM -0400, Willem de Bruijn wrote:
>> Applications receive tx timestamps from the kernel by reading the
>> original packet from the socket error queue with sendmsg() and
>> processing an ancillary data item that holds the timestamps.
>>
>> If the application is only interested in the timestamp, then looping
>> the whole packet back up to userspace wastes socket buffer space
>> (SO_RCVBUF). This is especially important when the same packet is
>> enqueued repeatedly with multiple timestamps.
>>
>> This patch adds a socket option to loop the timestamp on top of an
>> empty packet instead of a clone of the original.
>
> This makes sense. In practice the looped buffer is totally useless,
> due to the fact that many NICs can only handle one outstanding
> transmit time stamp. Applications must make sure they only send one
> packet at a time if they want every packet time stamped.
>
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 32cd1be..df7bde0 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -690,6 +690,7 @@ enum sock_flags {
>>       SOCK_TIMESTAMPING_SOFTWARE,     /* %SOF_TIMESTAMPING_SOFTWARE */
>>       SOCK_TIMESTAMPING_RAW_HARDWARE, /* %SOF_TIMESTAMPING_RAW_HARDWARE */
>>       SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
>> +     SOCK_TIMESTAMPING_OPT_TX_NO_PAYLOAD, /* %SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD */
>
> That is a bit of a mouthful. How about something like:
>
>  SOCK_TIMESTAMPING_PLAIN_TS
>  SOCK_TIMESTAMPING_BARE_TS
>  SOCK_TIMESTAMPING_TSONLY

Ack. I'll pick a shorter name. This also exceeded 80 chars.
>
>
> Thanks,
> Richard
