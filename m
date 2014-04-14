From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What causes these TCP packet getting lost in linux kernel
Date: Sun, 13 Apr 2014 22:27:01 -0700
Message-ID: <1397453221.4222.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>
	 <1397212866.16584.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>
	 <CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>
	 <1397331172.4222.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMRd1sV_ZzgFF8a2D=CsugHPHrNY=ifV1F46bKVwNSP9FvNPUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sharat Masetty <sharat04@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: chptx y <chptxy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:65172 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbaDNF1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 01:27:04 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so7734079pbc.6
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2014 22:27:03 -0700 (PDT)
In-Reply-To: <CAMRd1sV_ZzgFF8a2D=CsugHPHrNY=ifV1F46bKVwNSP9FvNPUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-04-14 at 13:02 +0800, chptx y wrote:
> Text exporting from wireshark, is it OK?
> ---------------------------------------------------------------------------------------------------------
> Frame 30: 168 bytes on wire (1344 bits), 168 bytes captured (1344 bits)
> Transmission Control Protocol, Src Port: http (80), Dst Port: 34865
> (34865), Seq: 12517, Ack: 3086, Len: 100
>     Source port: http (80)
>     Destination port: 34865 (34865)
>     [Stream index: 0]
>     Sequence number: 12517    (relative sequence number)
>     [Next sequence number: 12617    (relative sequence number)]
>     Acknowledgement number: 3086    (relative ack number)
>     Header length: 32 bytes
>     Flags: 0x010 (ACK)
>     Window size value: 7541
>     [Calculated window size: 7541]
>     [Window size scaling factor: 1]
>     Checksum: 0x89d8 [correct]
>         [Good Checksum: True]
>         [Bad Checksum: False]
>     Options: (12 bytes)
>     [SEQ/ACK analysis]
>     [Reassembled PDU in frame: 34]
>     TCP segment data (100 bytes)
> 
> Frame 31: 68 bytes on wire (544 bits), 68 bytes captured (544 bits)
> Transmission Control Protocol, Src Port: 34865 (34865), Dst Port: http
> (80), Seq: 3086, Ack: 12617, Len: 0
>     Source port: 34865 (34865)
>     Destination port: http (80)
>     [Stream index: 0]
>     Sequence number: 3086    (relative sequence number)
>     Acknowledgement number: 12617    (relative ack number)
>     Header length: 32 bytes
>     Flags: 0x010 (ACK)
>     Window size value: 5001
>     [Calculated window size: 40008]
>     [Window size scaling factor: 8]
>     Checksum: 0x8213 [incorrect, should be 0x1614 (maybe caused by
> "TCP checksum offload"?)]
>         [Good Checksum: False]
>         [Bad Checksum: True]
>     Options: (12 bytes)
>     [SEQ/ACK analysis]
> 
> Frame 32: 1416 bytes on wire (11328 bits), 1416 bytes captured (11328 bits)
> Transmission Control Protocol, Src Port: http (80), Dst Port: 34865
> (34865), Seq: 12617, Ack: 3086, Len: 1348
>     Source port: http (80)
>     Destination port: 34865 (34865)
>     [Stream index: 0]
>     Sequence number: 12617    (relative sequence number)
>     [Next sequence number: 13965    (relative sequence number)]
>     Acknowledgement number: 3086    (relative ack number)
>     Header length: 32 bytes
>     Flags: 0x010 (ACK)
>     Window size value: 7541
>     [Calculated window size: 7541]
>     [Window size scaling factor: 1]
>     Checksum: 0x4139 [correct]
>         [Good Checksum: True]
>         [Bad Checksum: False]
>     Options: (12 bytes)
>     [SEQ/ACK analysis]
>     [Reassembled PDU in frame: 34]
>     TCP segment data (1348 bytes)

Hard to say. We do not see the content of the TCP options. You might
receive invalid timestamps.

tcpdump -vv would tell us the needed information, with minimal
verbosity.
