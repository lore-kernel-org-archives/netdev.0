From: Alan Davey <Alan.Davey@metaswitch.com>
Subject: RE: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Wed, 15 Jun 2016 10:41:56 +0000
Message-ID: <BN3PR0201MB10599C7780CBC6EB4BC2894DF9550@BN3PR0201MB1059.namprd02.prod.outlook.com>
References: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com>
	<20160531.113913.1477085966766110028.davem@davemloft.net>
	<BN3PR0201MB1059316BEC3EC7F6CBF2F0E4F95E0@BN3PR0201MB1059.namprd02.prod.outlook.com>
 <20160608.102558.903056863834035706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0142.outbound.protection.outlook.com ([65.55.169.142]:43116
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753426AbcFOLQi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 07:16:38 -0400
In-Reply-To: <20160608.102558.903056863834035706.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



From: David Miller [mailto:davem@davemloft.net] 
Sent: 08 June 2016 18:26

>> -  The current behaviour is counter-intuitive (fragmentation takes
>> -  place in all other cases) and therefore different to what
>> -  everyone expects.
>
> But it's what all existing applications must expect, and as you have seen in these replied they absolutely do.
>
> You cannot just break things on people like this.

The only case that would break is that where an application relies on the existing (documented as a bug) feature of getting an EMSGSIZE return code in the case of an over-sized packet.  Applications that perform their own fragmentation would be unaffected.

I think that the benefit of the patch, in moving all fragmentation and reassembly into the kernel, outweigh the very small chance that applications rely on the send of an over-sized packet failing.

What is your thinking on taking the patch?

Regards
Alan
