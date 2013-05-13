From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with TSO
Date: Mon, 13 May 2013 14:40:24 -0700
Message-ID: <1368481224.13473.124.camel@edumazet-glaptop>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
	 <1368479056-11780-3-git-send-email-nsujir@broadcom.com>
	 <1368479644.13473.121.camel@edumazet-glaptop>
	 <51915C7D.2000407@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>, stable@vger.kernel.org
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <51915C7D.2000407@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-13 at 14:34 -0700, Nithin Nayak Sujir wrote:
> 
> On 05/13/2013 02:14 PM, Eric Dumazet wrote:

> >> +/* Test for TSO DMA buffers that cross into regions which are within MSS bytes
> >> + * of any 4GB boundaries: 4G, 8G, etc
> >> + */
> >> +static inline int tg3_4g_tso_overflow_test(struct tg3 *tp, dma_addr_t mapping,
> >> +					   u32 len, u32 mss)
> >> +{
> >> +	if (tg3_asic_rev(tp) == ASIC_REV_5762 && mss) {
> >> +		u32 base = (u32) mapping & 0xffffffff;
> >> +
> >> +		return ((base + len + (mss & 0x3fff)) < base);
> >> +	}
> >> +	return 0;
> >> +}
> >> +
> >
> > I am curious : Does this condition even triggers ?
> >
> 
> Yes, it's a rare problem to occur and was reported in our lab. After we 
> implemented this fix, the problem didn't happen again.
> 

I just cant figure out which part of the kernel could allocate a
fragment spanning a 4G region.
