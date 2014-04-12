From: Sharat Masetty <sharat04@gmail.com>
Subject: Re: What causes these TCP packet getting lost in linux kernel
Date: Sat, 12 Apr 2014 12:35:00 -0600
Message-ID: <CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>
References: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>
	<1397212866.16584.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: chptx y <chptxy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64611 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864AbaDLSfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 14:35:02 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so6702078wgh.27
        for <netdev@vger.kernel.org>; Sat, 12 Apr 2014 11:35:00 -0700 (PDT)
In-Reply-To: <CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check /proc/net/netstat and /proc/net/snmp

In netstat look for

LINUX_MIB_TCPOFODROP and LINUX_MIB_BACKLOGDROP

On Fri, Apr 11, 2014 at 9:06 PM, chptx y <chptxy@gmail.com> wrote:
> Thanks, Wireshark shows tcp checksum of this packet is correct, Any reason else?
>
> 2014-04-11 18:41 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> On Fri, 2014-04-11 at 15:19 +0800, chptx y wrote:
>>> Hi,
>>>
>>> I captured these packets with tcpdump on Android device(linux 3.4.39),
>>> these packets are in a HTTP GET Stream:
>>>
>>> 1  385.447794 Server -> Client: SEQ 12517, LEN 100
>>> 2  385.498345 Client -> Server: SEQ 3086, LEN 0, ACK 12617
>>> 3  385.497836 Server -> Client: SEQ 12617, LEN 1348
>>> 4  385.498644 Client -> Server: [DUP ACK] SEQ 3086, LEN 0, ACK 12617
>>> 5  385.498735 Server -> Client: SEQ 13965, LEN 619
>>> 6  385.498978 Client -> Server: [Dup ACK] SEQ 3086, LEN 0, ACK 12617
>>> 7  385.718843 Server -> Client: [Retrans] SEQ 13965, LEN 619
>>> 8  385.719280 Client -> Server: [DUP ACK] SEQ 3086, LEN 0, ACK 12617
>>> 9  385.733230 Server -> Client: [Retrans] SEQ 12617, LEN 1348
>>> 10 385.733602 Client -> Server: SEQ 3086, LEN 0, ACK 14584
>>> 11 385.909921 Server -> Client: [Retrans] SEQ 12617, LEN 1348
>>> 12 385.910449 Client -> Server: [DUP ACK][Window Upd.] SEQ 3086, LEN
>>> 0, ACK 14584
>>> 13 388.031541 Client -> Server: SEQ 832, LEN 0, ACK 4192, FIN
>>> 14 388.031681 Client -> Server: SEQ 3086, LEN 0, ACK 14584, FIN
>>>
>>> Client is my device run tcpdump on.
>>>
>>> packet #3 (SEQ 12617) has been captured yet, Is there any problem in
>>> kernel causes this packet getting lost in upper layer? why does kernel
>>> send packet #4 (DUP ACK) repeatedly?
>>
>> Frame could be rejected because of a checksum error
>>
>> tcpdump -vv (On the android device)
>>
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
