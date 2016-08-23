From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 1/3] net/ip_tunnels: Introduce
 tunnel_id_to_key32() and key32_to_tunnel_id()
Date: Tue, 23 Aug 2016 09:39:49 +0300
Message-ID: <20160823063949.GA9128@office.localdomain>
References: <20160822143834.32422-1-amir@vadai.me>
 <20160822143834.32422-2-amir@vadai.me>
 <20160822190027.6b4e6028@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33624 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756680AbcHWGjx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 02:39:53 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so16637903wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 23:39:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160822190027.6b4e6028@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 07:00:27PM +0200, Jiri Benc wrote:
> While cleaning this up, you may as well take the best of both
> implementations.
> 
> On Mon, 22 Aug 2016 17:38:32 +0300, Amir Vadai wrote:
> > +static inline __be64 key32_to_tunnel_id(__be32 key)
> > +{
> > +#ifdef __BIG_ENDIAN
> > +	return (__force __be64)((__force u32)key);
> 
> The inner cast seems to be superfluous?
seems so. will check.

> 
> > +#else
> > +	return (__force __be64)((__force u64)key << 32);
> > +#endif
> > +}
> > +
> > +/* Returns the least-significant 32 bits of a __be64. */
> > +static inline __be32 tunnel_id_to_key32(__be64 x)
> 
> Please use a more descriptive name than "x". "tunnel_id" or "tun_id"
> seems to be more appropriate.
ack

> 
> > +{
> > +#ifdef __BIG_ENDIAN
> > +	return (__force __be32)x;
> > +#else
> > +	return (__force __be32)((__force u64)x >> 32);
> > +#endif
> > +}
> 
> Looks good otherwise.
> 
> Thanks,
> 
>  Jiri
