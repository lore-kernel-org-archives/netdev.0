From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 14:28:38 -0800
Message-ID: <1454106518.7627.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129.110634.1678121731419241040.davem@davemloft.net>
	 <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129194434.GC17127@oracle.com>
	 <1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0UdXBHocMwdcQHHd5bGMUofEH6ENox=Jw_vLEn3kMonmhA@mail.gmail.com>
	 <1454103195.7627.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0Udwjgmbwd2StNm-e-02Th4NHetb_FMbrU=KOCHf_90YbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34793 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbcA2W2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 17:28:40 -0500
Received: by mail-pa0-f48.google.com with SMTP id uo6so48745585pac.1
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 14:28:40 -0800 (PST)
In-Reply-To: <CAKgT0Udwjgmbwd2StNm-e-02Th4NHetb_FMbrU=KOCHf_90YbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 14:08 -0800, Alexander Duyck wrote:

> It also means DMA becomes dramatically slower as it introduces a
> partial write access for the start of every frame.  It is why we had
> set NET_IP_ALIGN to 0 on x86 since DMA was becoming more expensive
> when unaligned then reading IP unaligned headers.

Well, I guess that if you have an arch where DMA accesses are slow and
NET_IP_ALIGN = 2, you are out of luck. This is why some platforms are
better than others.


> 
> The gain on recvmsg would probably be minimal.  The only time I have
> seen any significant speed-up for copying is if you can get both ends
> aligned to something like 16B.

On modern intel cpus, this does not matter at all, sure. It took a while
before "rep movsb" finally did the right thing.

memcpy() and friends implementations are much slower on some older
arches (when dealing with unaligned src/dst)

arch/mips/lib/memcpy.S is a gem ;)
