From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Tue, 14 Feb 2017 23:29:35 +0100
Message-ID: <20170214232935.34f9e6a1@redhat.com>
References: <20170208234127.3041579-1-tom@herbertland.com>
        <20170208234127.3041579-2-tom@herbertland.com>
        <20170214213157.32e37148@redhat.com>
        <CALx6S34mpo+Q_gsP37ENDqC8yEhk9s=in9v0S_c26z0JTM=adQ@mail.gmail.com>
        <CALx6S35C3SYvaBT93VsDJW4gej30MXD1PqjN53cfqG00L=NM3g@mail.gmail.com>
        <6d605909-b049-9a8d-05a9-32b715c30527@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>, brouer@redhat.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54128 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751375AbdBNW3j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 17:29:39 -0500
In-Reply-To: <6d605909-b049-9a8d-05a9-32b715c30527@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Feb 2017 22:08:10 +0000
Edward Cree <ecree@solarflare.com> wrote:

> To me, the sensible interface (which makes the batching explicit to
>  the driver, which I think is necessary) is to have an int (or maybe
>  unsigned int, which is the return type of xdp_hookfn, I'm not sure
>  which is intended) member in struct xdp_buff.
>
> Then the driver can call something like
> 	XDP_RUN_ARRAY(napi, xdp_array, array_len);
> which is semantically equivalent to
> 	unsigned int i;
> 	for (i = 0; i < array_len; i++)
> 		xdp_array[i].ret = xdp_hook_run(napi, xdp_array + i);

Yes, exactly.

I imagined the xdp_array[i].ret would be the XDP action return code.

> except that it may run the hooks in 'row-major order'.
> No callbacks needed, the driver can just loop over xdp_array reading
>  the .ret and applying the relevant action to each packet.
> 
> This also has the advantage that the driver knows how many packets it
>  might have to process in a single batch (i.e. NAPI_POLL_WEIGHT) and
>  can allocate the array statically, whereas an XDP hook that tried to
>  transparently be 'helpful' would have to guess and/or use kmalloc.

I also think the driver need to be explicit about batching.

This related to the RX stages I'm talking about.  Saeed is working on
implementing that for mlx5, I got some PoC patches today and I'll soon
test that.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
