From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: on [ab]use of skb->cb by VLAN code
Date: Mon, 30 Jul 2007 22:33:18 -0700
Message-ID: <46AEC99E.10809@candelatech.com>
References: <1185847324.5162.31.camel@localhost>	<20070730.190621.13770511.davem@davemloft.net>	<46AEBADB.7030007@candelatech.com> <20070730.221847.74747100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	mcarlson@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:41890 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756120AbXGaFiW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 01:38:22 -0400
In-Reply-To: <20070730.221847.74747100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Mon, 30 Jul 2007 21:30:19 -0700
>
>   
>> So, shall we add a new field to the skb in order to get the info out of cb?
>>
>> Looks like a single 32-bit field would be sufficient.
>>     
>
> I'm trying to brainstorm how to avoid consuming new space in
> sk_buff and I'd like others to do so as well.
>
> This isn't super urgent at all so I'll just think about it
> on the backburner, things like the NAPI changes and dealing
> with all of today's networking bug fixes is my top priority
> at the moment.
>   
Ok.  From a quick look through skbuff.h, here is an idea:

Do we really need an 'unsigned int' for mac_len?  Maybe we could use
a 16-bit counter here, and then use the other 16 bits for the VLAN bits?
(I now think that only 16 bits are needed for VLAN, because it looks 
like the
NICs must know how to grab the vlan encapsulated protocol out of the 
skb??  Or,
maybe I just got confused when reading the vlan hwaccel logic...)

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


