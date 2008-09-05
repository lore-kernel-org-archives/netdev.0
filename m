From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 16:45:13 +0200
Message-ID: <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com>
References: <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com>
	 <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com>
	 <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com>
	 <20080905113112.GA29926@2ka.mipt.ru>
	 <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com>
	 <20080905131618.GB12246@2ka.mipt.ru>
	 <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com>
	 <20080905133748.GA28656@2ka.mipt.ru>
	 <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com>
	 <20080905141911.GA16586@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:55077 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbYIEOpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 10:45:14 -0400
Received: by rv-out-0506.google.com with SMTP id k40so479851rvb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 07:45:13 -0700 (PDT)
In-Reply-To: <20080905141911.GA16586@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

>
> No need to run FTRACE, code shuld be audited and probably some debug
> prints added to determine, why sendfile() decides to exit early wiht
> UDP. I will try to do it if time permits this weekend, although I'm
> quite surprised sendfile() does not work with UDP...
>

I've finally made the test:
Packet is not going through device due to this test:
	if (inet->cork.length + size > 0xFFFF - fragheaderlen) {
		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
		return -EMSGSIZE;
	}
in ip_append_page()

inet->cork.length reach 61448 then this failure occurs
size = 4096
fragheaderlen = 20


>
> You can always provide a global offset where to put next packet.
> You can ajust it to put header before each data frame, and then DMA
> frame content according to that offset.
>
> Transmitting packet socket is needed for those, who wants to implement
> own low-level protocol unsupported by the kernel, so to transfer data
> over UDP or TCP over IP with the highests speeds, one should use
> existing methods. This does not of course mean, that anyone _has_ to do
> it, it is always very fun to find new ways like your patch.
>

What do you mean with global offset ?

Thanks,
Johann
-- 
Johann Baudy
johaahn@gmail.com
