From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 15:29:25 +0200
Message-ID: <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com>
References: <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com>
	 <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com>
	 <20080903220347.GA22395@2ka.mipt.ru>
	 <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com>
	 <20080905071754.GA25998@2ka.mipt.ru>
	 <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com>
	 <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com>
	 <20080905113112.GA29926@2ka.mipt.ru>
	 <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com>
	 <20080905131618.GB12246@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:46088 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbYIEN30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 09:29:26 -0400
Received: by rv-out-0506.google.com with SMTP id k40so453202rvb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 06:29:26 -0700 (PDT)
In-Reply-To: <20080905131618.GB12246@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evegniy


> Yes, and we found, that vmsplice() is slow, so unacceptible.
> What about single big enough file being sent via sendfile()?
> Can it saturate the link in your setup?

I'm trying to. But so far not able to saturate the link.

>
> It looks like you are sending data in chunks, which you should not do.
> Why do you splice input file into 60k chunks for UDP?
> sendfile() should iterate over whole file in page chunks, pack them
> into splice buffer (16 pages), send them, then get next set of pages
> and so on... udp_sendpage() will properly allocate skbs for the given
> MTU, or append data to the end of the skb if there is a place.
>
> You should _not_ manually interrupt this process and call sendfile()
> multiple times with different offsets and small sizes.
>

So, it seems that there is something wrong in UDP here, because TCP
works properly with same code.
If size argument of sendfile() exceed 61440, sendfile() returns 61440
and send no data to the device ...
I will try to investigate it but for my app sendfile() is not
conceivable. Only vmsplice could, but too slow.

Thanks,
Johann

-- 
Johann Baudy
johaahn@gmail.com
