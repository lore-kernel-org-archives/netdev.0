From: Harley Stenzel <hstenzel@us.ibm.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Wed, 20 Aug 2003 08:52:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F436EF9.1040502@us.ibm.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB5D@post.pc.aspectgroup.co.uk> <20030819112103.373fce27.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Underwood <richard@aspectgroup.co.uk>, skraw@ithnet.com,
   willy@w.ods.org, alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com,
   lamont@scriptkiddie.org, davidsen@tmr.com, bloemsaa@xs4all.nl,
   marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819112103.373fce27.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 19 Aug 2003 19:05:13 +0100
> Richard Underwood <richard@aspectgroup.co.uk> wrote:
> 
>>	The ARP request represents all FUTURE
>>packets being sent out that interface, not just the one single packet that
>>happened to kick of this ARP request.
> 
> That's RIGHT!  And by your own argument the source address
> in the ARP request IS IRRELEVANT and is to be ignored!
> 

The source address in the ARP request is not irrelevant, because a 
broadcast arp request causes all recipients of that broadcast request to 
update their arp cache entry (if they have a cache entry for that IP) 
for the IP specified in the source with the MAC specified in the request.

So, in an environment where a single address is aliased in multiple 
places, such as tunnel endpoints and loopback aliases, and in 
multi-homed same-segment configs, it is unpredictable asto which IP will 
be bound to which MAC for every machine (or arp cache) on the network.

--Harley
