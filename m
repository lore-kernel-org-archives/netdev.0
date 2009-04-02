From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 14:59:26 +0300
Message-ID: <49D4A89E.5090407@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <20090402091639.GA30126@gondor.apana.org.au> <49D484F5.2000400@redhat.com> <20090402092936.GA30333@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	Mark McLoughlin <markmc@redhat.com>
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D49C1F.6030306@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:

  

>> Why does a kernel solution not need to know when a packet is transmitted?
>>
>>     
>
> You do not need to know when the packet is copied (which I currently
> do).  You only need it for zero-copy (of which I would like to support,
> but as I understand it there are problems with the reliability of proper
> callback (i.e. skb->destructor).
>
> Its "fire and forget" :)
>   

It's more of a "schedule and forget" which I think brings you the win.  
The host disables notifications and schedules the actual tx work (rx 
from the host's perspective).  So now the guest and host continue 
producing and consuming packets in parallel.  So long as the guest is 
faster (due to the host being throttled?), notifications continue to be 
disabled.

If you changed your rx_isr() to process the packets immediately instead 
of scheduling, I think throughput would drop dramatically.

Mark had a similar change for virtio.  Mark?

-- 
error compiling committee.c: too many arguments to function

