From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] xfrm6: Do not use xfrm_local_error for path MTU issues
 in tunnels
Date: Thu, 28 May 2015 00:18:51 -0700
Message-ID: <5566C15B.7090403@gmail.com>
References: <20150527173823.1415.96248.stgit@ahduyck-vm-fedora22> <20150528053607.GF27342@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150528053607.GF27342@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/27/2015 10:36 PM, Steffen Klassert wrote:
> On Wed, May 27, 2015 at 10:40:32AM -0700, Alexander Duyck wrote:
>> This change makes it so that we use icmpv6_send to report PMTU issues back
>> into tunnels in the case that the resulting packet is larger than the MTU
>> of the outgoing interface.  Previously xfrm_local_error was being used in
>> this case, however this was resulting in no changes, I suspect due to the
>> fact that the tunnel itself was being kept out of the loop.
>>
>> This patch fixes PMTU problems seen on ip6_vti tunnels and is based on the
>> behavior seen if the socket was orphaned.  Instead of requiring the socket
>> to be orphaned this patch simply defaults to using icmpv6_send in the case
>> that the frame came though a tunnel.
> We can use icmpv6_send() just in the case that the packet
> was already transmitted by a tunnel device, otherwise we
> get the bug back that I mentioned in my other mail.
>
> Not sure if we have something to know that the packet
> traversed a tunnel device. That's what I asked in the
> thread 'Looking for a lost patch'.

Okay I will try to do some more digging.  From what I can tell right now 
it looks like my ping attempts are getting hung up on the 
xfrm_local_error in __xfrm6_output.  I wonder if we couldn't somehow 
make use of the skb->cb to store a pointer to the tunnel that could be 
checked to determine if we are going through a VTI or not.

- Alex
