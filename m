From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 18:45:54 -0500
Message-ID: <42362232.4070202@pobox.com>
References: <20050314123815.73e7ee78.davem@davemloft.net>	<200503142054.j2EKs2DD003697@guinness.s2io.com> <m1br9l6c63.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Leonid Grossman <leonid.grossman@neterion.com>, netdev@oss.sgi.com,
        leonid@neterion.com, alex@neterion.com,
        "David S. Miller" <davem@davemloft.net>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1br9l6c63.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> "Leonid Grossman" <leonid.grossman@neterion.com> writes:
> 
>>Do you have other objections to the submission? We'd like to see if these
>>could be addressed; going forward we see significant benefits both for
>>S2io/Neterion (and our customers) and for community to use this driver.
> 
> 
> I guess the main objection to the HAL comes not from performance
> issues (Usually the only thing that really counts for performance
> is data cache misses and the HAL is unlikely to affect this much), but
> the coding style etc.. Indeed it does not look too Linux like. 

Well, not coding style, but code analysis and maintenance issues.

HALs are generally type-opaque, breaking checker-style tools and sparse 
checks.

"it looks like Linux code" has implications on bug finding and fixing, 
and long term maintenance of the code.  You want to make it easy for 
someone to make the same change across N net drivers.

Because most ->hard_start_xmit() hooks were written in a similar 
fashion, it was easy and quick to deploy fixes for the skb_padto() 
security bug across many net drivers.

A lot of tiny costs that mostly wind up as noise:  additional branching 
/ derefs.

My biggest objection is that HALs increase the overall "cost" of 
maintaining a piece of code, and serve as a barrier against outside 
(non-primary-author) kernel hacker involvement.

Remember, this driver is going to be with us for -10- years or more.

	Jeff
