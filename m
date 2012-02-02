From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Thu, 2 Feb 2012 17:43:16 +0200
Message-ID: <4F2AAF14.5060701@mellanox.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>   <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>   <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>   <4F264A6C.3070706@mellanox.com> <1327910672.2891.12.camel@edumazet-laptop>   <20120130081849.GA7848@gondor.apana.org.au>   <1327913583.2288.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <20120130085742.GA8262@gondor.apana.org.au>   <CAJZOPZJb1HvcS0XXKLvoDuoi1EfYTY-awwY2g0aHWoS=4qmdyQ@mail.gmail.com>   <20120201083837.GA7081@gondor.apana.org.au>   <CAJZOPZJVAQoy0B30zqkROOBp_-bF6=EdU2L9V025fJgTexVuFQ@mail.gmail.com>  <1328105262.2595.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4F2A974B.209@mellanox.com> <1328193495.2279.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328193495.2279.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/2/2012 4:38 PM, Eric Dumazet wrote:
>>> Maybe we can keep a fastpath for ethernet case... (the "if (hlen == ETH_HLEN) being always predicted) Maybe need to introduce gro_hard_header_len as well)
>>
>> today, IPoIB advertizes hard_header_len which is bigger than the IPoIB
>> header len, this is done such that skbs sent by the network stack have
>> enough headroom for a "pseudoheader" which for few flows (e.g unicast
>> arp replies and multicast) is placed there by the ipoib hard_header
>> function and later used by the xmit function.
>>
>> So we can either try and change that, such that hard_header_len will be equal to the ipoib header len or add gro_hard_header_len as you  suggested, any preferences?
>
> I guess changing hard_header_len might be difficult (for you).
> Adding gro_mac_header_len sounds the easy way. [ You'll need to set it in your device setup() ]


Eric, yep, I'm okay with adding gro_mac_header_len, such that if the 
device setup function doesn't touch it, the core sets it to 
hard_header_len and later the gro code uses that len in the comparison 
you have placed in your patch.  The ipoib setup code will set that field 
to the IPoIB header size. If you enhance a bit your patch to include 
that I could do the testing or you prefer me to do that? do you think we 
need two or one patch here?

Or.



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
