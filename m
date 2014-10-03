From: Jason Baron <jbaron@akamai.com>
Subject: Re: macvlan: optimizing the receive path?
Date: Fri, 03 Oct 2014 11:08:10 -0400
Message-ID: <542EBBDA.8070209@akamai.com>
References: <542DB55D.3090601@akamai.com> <20141002143136.2234c9e6@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:54684 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753450AbaJCPIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:08:12 -0400
In-Reply-To: <20141002143136.2234c9e6@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2014 05:31 PM, Stephen Hemminger wrote:
> On Thu, 02 Oct 2014 16:28:13 -0400
> Jason Baron <jbaron@akamai.com> wrote:
> 
>> Hi,
>>
>> I was just wondering why the netif_rx(skb) call in macvlan_handle_frame()
>> was necessary? IE:
> 
> 
> It is to prevent too deep a call stack of
>   netif_receive_skb
>      macvlan_receive
>         netif_receive_skb ...
> 

So the concern is a stack overflow? The above nesting would really look like:

netif_receive_skb
        macvlan_receive
netif_receive_skb

b/c the macvlan_receive call would return. So its not clear to me that the
macvlan code would be adding to the stack depth here.

Thanks,

-Jason
