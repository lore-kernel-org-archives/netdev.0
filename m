From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [Devel] [PATCH 1/5] Cut off br_port fied from net_device
Date: Mon, 22 Oct 2007 17:02:49 +0400
Message-ID: <471C9F79.4030407@openvz.org>
References: <471C9830.5070407@openvz.org> <471C989D.9030207@openvz.org> <20071022124915.GD6271@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50694 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbXJVNCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 09:02:43 -0400
In-Reply-To: <20071022124915.GD6271@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On Mon, Oct 22, 2007 at 04:33:33PM +0400, Pavel Emelyanov wrote:
>> And add the forward declaration for br_handle_frame_hook in
>> include/linux/if_bridge.h
> 
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -699,8 +699,10 @@ struct net_device
>>  	/* Network namespace this network device is inside */
>>  	struct net		*nd_net;
>>  
>> +#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
>>  	/* bridge stuff */
>>  	struct net_bridge_port	*br_port;
>> +#endif
> 
> Such ifdefs are troublesome, because one can compile kernel with
> CONFIG_BRIDGE=n and later decide he needs BRIDGE=m and go boom.

You will have to recompile the whole kernel when this config
is on. Look at netif_receive_skb() ;)

> IPv6 -- the biggest violator of this rule should not be taken as
> example. :^)
> 
> 

