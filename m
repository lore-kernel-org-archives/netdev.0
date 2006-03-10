From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TSO and IPoIB performance degradation
Date: Fri, 10 Mar 2006 09:44:59 -0800
Message-ID: <4411BB1B.1020804@hp.com>
References: <20060308125311.GE17618@mellanox.co.il>	<20060309.154819.104282952.davem@davemloft.net>	<4410C671.2050300@hp.com>
	<20060309.232301.77550306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: netdev@vger.kernel.org
In-Reply-To: <20060309.232301.77550306.davem@davemloft.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 09 Mar 2006 16:21:05 -0800
> 
> 
>>well, there are stacks which do "stretch acks" (after a fashion) that 
>>make sure when they see packet loss to "do the right thing" wrt sending 
>>enough acks to allow cwnds to open again in a timely fashion.
> 
> 
> Once a loss happens, it's too late to stop doing the stretch ACKs, the
> damage is done already.  It is going to take you at least one
> extra RTT to recover from the loss compared to if you were not doing
> stretch ACKs.

I must be dense (entirely possible), but how is that absolute?

If there is no more data in flight after the segment that was lost the 
"stretch ACK" stacks with which I'm familiar will generate the 
standalone ACK within the deferred ACK interval (50 milliseconds). I 
guess that can be the "one extra RTT"  However,  if there is data in 
flight after the point of loss, the immediate ACK upon receipt of out-of 
order data kicks in.

> You have to keep giving consistent well spaced ACKs back to the
> receiver in order to recover from loss optimally.

The key there is defining consistent and well spaced.  Certainly an ACK 
only after a window's-worth of data would not be well spaced, but I 
believe that an ACK after more than two full sized frames could indeed 
be well-spaced.

> The ACK every 2 full sized frames behavior of TCP is absolutely
> essential.

I don't think it is _quite_ that cut and dried, otherwise, HP-UX and 
Solaris, since < 1997 would have had big time problems.

rick jones
