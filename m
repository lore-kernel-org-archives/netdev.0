From: Chris Leech <chris.leech@gmail.com>
Subject: Re: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Thu, 14 Oct 2004 13:49:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41b516cb04101413492af4db1d@mail.gmail.com>
References: <416E9550.4060001@pobox.com>
	 <200410141833.i9EIXI39018452@guinness.s2io.com>
Reply-To: Chris Leech <chris.leech@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, ravinandan.arakali@s2io.com,
        Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Raghavendra Koushik <raghavendra.koushik@s2io.com>
In-Reply-To: <200410141833.i9EIXI39018452@guinness.s2io.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 14 Oct 2004 11:33:13 -0700, Raghavendra Koushik
<raghavendra.koushik@s2io.com> wrote:

> > 1) can this not be done with SKB fragments?
> > 
> To acheve what is required, the H/W still has to split the Rx'ed frame into
> 2 parts. By implementing this through the SKB fragments method, the only
> thing we avoid is usage of ba_0 and ba_1 fields, but note that none of these
> are allocated or freed in fast path. They are all pre-allocated buffers
> (along with the Rx descriptors) and hence won't hit the Rx side performance.
> Also by pulling down the eth_type_trans implementation partially into the
> driver any kind of copy during Rx is also avoided.

This change would pass skbs from the driver without the MAC header? 
What happens in a bridging configuration?  And dev->hard_header_parse
is set to eth_header_parse, which expects skb->mac.ethernet to be
valid, so I think any use of packet sockets will result in a NULL
dereference.

- Chris
