From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What causes these TCP packet getting lost in linux kernel
Date: Mon, 14 Apr 2014 11:32:55 -0700
Message-ID: <1397500375.4222.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>
	 <1397212866.16584.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>
	 <CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>
	 <1397331172.4222.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMRd1sV_ZzgFF8a2D=CsugHPHrNY=ifV1F46bKVwNSP9FvNPUw@mail.gmail.com>
	 <534B9EBC.4000606@davidnewall.com>
	 <CAMRd1sWa70D3Cjx74jC8g2fJKXho=okrpu+HfsZmu77-70c4DQ@mail.gmail.com>
	 <1397484804.4222.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJzFV34Z077yQv71X8WSQ2U-6iCNPnsPDBNaSFoQabxHG_q-2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chptx y <chptxy@gmail.com>, David Newall <davidn@davidnewall.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:53266 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbaDNSc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 14:32:57 -0400
Received: by mail-pb0-f50.google.com with SMTP id md12so8601466pbc.9
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 11:32:57 -0700 (PDT)
In-Reply-To: <CAJzFV34Z077yQv71X8WSQ2U-6iCNPnsPDBNaSFoQabxHG_q-2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-04-14 at 11:58 -0600, Sharat Masetty wrote:
> Thats a good find.. Is this drop count documented in netstat stats?


Sure  : LINUX_MIB_PAWSESTABREJECTED

nstat -a | grep PAWSEstab

> 
> On Mon, Apr 14, 2014 at 8:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2014-04-14 at 17:20 +0800, chptx y wrote:
> >> i don't know why, no matter I capture packets on my Ubuntu PC or
> >> Android device with tcpdump,  open the output file with wireshark, all
> >> output packets are marked with "incorrect checksum", but it seems that
> >> this problem don't affect  subsequent packets interaction. why?
> >
> > Checksums are filled by the NIC on TX packets, some tcpdump/wireshark
> > versions do not really know of this.
> >
> > packet 30 (which is accepted) has TSval=4054079470 & TSecr=22894,
> > but packet 32 has TSval=4054078149 & TSecr=22863, while its sequence is
> > correct (coming after the prior packet)
> >
> > Sender has a wrong implementation of TCP Timestamps (RFC 1323), or a
> > middlebox mangles timestamps badly.
> >
> > Receiver considers this as an old packet.
> >\
