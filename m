From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH net-next] ppp: Allow ppp device connected to an l2tp
 session to change of namespace
Date: Thu, 24 Oct 2013 17:51:30 +0100
Message-ID: <52695012.6090700@katalix.com>
References: <5268F6CD.9070600@alphalink.fr> <5268FCB1.7020903@katalix.com> <526923A7.8090108@alphalink.fr> <5269402E.2070203@katalix.com> <20131024155354.GQ2704@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Fran=E7ois_Cachereul?= <f.cachereul@alphalink.fr>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20131024155354.GQ2704@kvack.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24/10/13 16:53, Benjamin LaHaise wrote:
> On Thu, Oct 24, 2013 at 04:43:42PM +0100, James Chapman wrote:
>> I'm thinking about the implications of a skb in the net namespace of the
>> ppp interface passing through a tunnel socket which is in another
>> namespace. I think net namespaces are completely isolated.
>>
>> To keep your ppp interfaces isolated from each other, have you
>> considered using netfilter to prevent data being passed between ppp
>> interfaces?
> 
> Using network namespaces for this is far more efficient.  We've already 
> added support for doing this to other tunneling interfaces.  This approach 
> also makes creating VPNs where there is re-use of the private address space 
> between different customers far easier to implement.
> 
> 		-ben

Yes, it's definitely more efficient and potentially useful, I agree.

But unlike the other tunneling interfaces for which this has already
been done, L2TP uses a socket for its tunnel and a skb will cross net
namespace boundaries while passing through the socket. I remember a
similar discussion came up several months ago with vxlan which also uses
UDP sockets. See http://www.spinics.net/lists/netdev/msg221498.html.

Changing the behaviour of ppp interfaces only when they are created by
l2tp feels wrong to me, unless it is the first step in doing the same
for all ppp interfaces.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
