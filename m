From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Mon, 01 Feb 2016 09:25:41 -0800
Message-ID: <1454347541.7627.171.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129.110634.1678121731419241040.davem@davemloft.net>
	 <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129194434.GC17127@oracle.com>
	 <1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0UdXBHocMwdcQHHd5bGMUofEH6ENox=Jw_vLEn3kMonmhA@mail.gmail.com>
	 <1454103195.7627.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0Udwjgmbwd2StNm-e-02Th4NHetb_FMbrU=KOCHf_90YbA@mail.gmail.com>
	 <1454106518.7627.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CCD25BC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36011 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbcBARZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 12:25:43 -0500
Received: by mail-pf0-f170.google.com with SMTP id n128so86472870pfn.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 09:25:43 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD25BC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-02-01 at 16:55 +0000, David Laight wrote:
> From: Eric Dumazet
> > Sent: 29 January 2016 22:29
> ...
> > On modern intel cpus, this does not matter at all, sure. It took a while
> > before "rep movsb" finally did the right thing.
> 
> Unfortunately memcpy_to_io() etc now map to 'rep movsb', and that can
> only be optimisied for cached addresses.
> 
> So copies to/from pcie space get done as byte copies, slower than slow.
> 
> The same is true when usespace has used mmap() to directly access
> pcie memory.
> 
> There isn't a standard wrapper than generates 'rep movsd'.

If memcpy_to_io() has problem because it assumed memcpy() had some
properties, it is quite a different problem that should be referred to
x86 maintainers ?

arch/x86/lib/memcpy_64.S certainly contains a suitable variant.
