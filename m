From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What causes these TCP packet getting lost in linux kernel
Date: Mon, 14 Apr 2014 07:13:24 -0700
Message-ID: <1397484804.4222.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>
	 <1397212866.16584.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>
	 <CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>
	 <1397331172.4222.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMRd1sV_ZzgFF8a2D=CsugHPHrNY=ifV1F46bKVwNSP9FvNPUw@mail.gmail.com>
	 <534B9EBC.4000606@davidnewall.com>
	 <CAMRd1sWa70D3Cjx74jC8g2fJKXho=okrpu+HfsZmu77-70c4DQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Newall <davidn@davidnewall.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: chptx y <chptxy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:58753 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbaDNON0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:13:26 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so8317915pab.10
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 07:13:25 -0700 (PDT)
In-Reply-To: <CAMRd1sWa70D3Cjx74jC8g2fJKXho=okrpu+HfsZmu77-70c4DQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-04-14 at 17:20 +0800, chptx y wrote:
> i don't know why, no matter I capture packets on my Ubuntu PC or
> Android device with tcpdump,  open the output file with wireshark, all
> output packets are marked with "incorrect checksum", but it seems that
> this problem don't affect  subsequent packets interaction. why?

Checksums are filled by the NIC on TX packets, some tcpdump/wireshark
versions do not really know of this.

packet 30 (which is accepted) has TSval=4054079470 & TSecr=22894,
but packet 32 has TSval=4054078149 & TSecr=22863, while its sequence is
correct (coming after the prior packet)

Sender has a wrong implementation of TCP Timestamps (RFC 1323), or a
middlebox mangles timestamps badly.

Receiver considers this as an old packet.
