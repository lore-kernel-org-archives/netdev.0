From: Baruch Even <baruch@ev-en.org>
Subject: Re: netif_rx packet dumping
Date: Thu, 03 Mar 2005 21:44:52 +0000
Message-ID: <42278554.2090902@ev-en.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>	<42278122.6000000@ev-en.org> <20050303133659.0d224e61.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, rhee@eos.ncsu.edu, jheffner@psc.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050303133659.0d224e61.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 03 Mar 2005 21:26:58 +0000
> Baruch Even <baruch@ev-en.org> wrote:
> 
> 
>>I have patches for the SACK processing to improve performance which 
>>should reduce the problems with the queues, but they are for 2.6.6 and 
>>forward porting them to 2.6.11 is quite a bit of work (too much was 
>>changed in conflicting areas). I hope to get to work on this soon.
> 
> Please split up your patches properly this time.  Last time you
> split up the patches, there was common changes in several of the
> patch files.  It looked like you just hand edited the patches in
> order to split up the changes, or something like that, and it's
> very error prone and made review impossible.

That was before my time, I've cleaned that up since then.

> And I'm not accepting your changes if you're going to still add all
> that linked list stuff to the generic struct sk_buff.  Adding anything
> new to sk_buff is going to make it straddle more L2 cache lines on
> ia64 and other 64-bit systems and that totally kills performance.

That's a bit more of a problem, that's the exact performance improvement 
we are trying to add!

The current linked list goes over all the packets, the linked list we 
add is for the packets that were not SACKed. The idea being that it is a 
lot faster since there are a lot less packets not SACKed compared to 
packets already SACKed (or never mentioned in SACKs).

If you have a way around this I'd be happy to hear it.

Baruch
