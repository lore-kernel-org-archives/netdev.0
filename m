From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Virtual ethernet tunnel (v.2)
Date: Thu, 07 Jun 2007 09:35:52 -0700
Message-ID: <466833E8.4020904@candelatech.com>
References: <4667E83E.2060405@openvz.org> <466822DD.1000601@candelatech.com> <466826C6.6000206@openvz.org> <46682976.8050904@candelatech.com> <46682C87.1080702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Kirill Korotaev <dev@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:51172 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761652AbXFGQlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 12:41:07 -0400
In-Reply-To: <46682C87.1080702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:

> Hmm... The loopback must be doing bad things then. It first calls
> eth_type_trans and then accounts for the new skb->len.

Perhaps it should be changed.  e100 calculates the entire
frame as far as I can tell, and e1000 and tg3 do it in hardware
(not sure what all they are counting, but I *think* it includes
the header...)

VLANs calculate before pulling it's header, though the ethernet
header has already been pulled by the time VLAN sees the skb.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

