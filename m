From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: Wed, 31 Mar 2004 09:30:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406B001A.1030901@candelatech.com>
References: <200403311201.i2VC13D19579@zero.aec.at> <Pine.LNX.4.58.0403311552070.19615@rhea.tcs.hut.fi> <20040331135449.GB62402@colin2.muc.de> <Pine.LNX.4.58.0403311705460.19615@rhea.tcs.hut.fi> <20040331151047.GA6033@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ville Nuorvala <vnuorval@tcs.hut.fi>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20040331151047.GA6033@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Wed, Mar 31, 2004 at 05:24:47PM +0300, Ville Nuorvala wrote:
> 
>>There just doesn't seem to be any general flag field in sk_buff that we
>>might use at this moment. Should one be added, or should we just hide the
>>flag inside the cb field using the likes of inet_skb_parm and
>>inet6_skb_parm?
> 
> 
> There are no free bits indeed. I think ->cb is the best choice then.

Why not add a 32-bit field to the skb to handle various flag needs
going forward?

If space is very important, could use an uint16 for flags and consolidate
the ip_summed and cloned fields, which seem to be boolean fields.

	unsigned char		local_df,
				cloned,
				pkt_type,
				ip_summed;
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
