From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Thu, 13 Oct 2011 17:59:42 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab>
 <20111010223752.GB2373@minipsycho>
 <1318518274.9266.94.camel@sakura.staff.proxad.net>,<20111013153850.GA2031@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: Jiri Pirko <jpirko@redhat.com>, Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:51653 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397Ab1JMP7o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 11:59:44 -0400
In-Reply-To: <20111013153850.GA2031@minipsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 13, 2011 at 05:04:34PM CEST, mbizon@freebox.fr wrote:
>>
>>On Tue, 2011-10-11 at 00:37 +0200, Jiri Pirko wrote:
>>
>>> Hmm, I must look at this again tomorrow but I have strong feeling this
>>> will break some some scenario including vlan-bridge-macvlan.
>>
>>unless I'm mistaken, today's behaviour:
>>
>># vconfig add eth0 100
>># brctl addbr br0
>># brctl addif br0 eth0
>>
>>=> eth0.100 gets no more packets, br0.100 is to be used
>>
>>after the patch won't we get the opposite ?
>
>Looks like it. The question is what is the correct behaviour...

I think this it become correct now, you should not destroy lover level if possible.
I.e. as John wrote "it's not an unexpected behaviour"

Consider adding a bridge to a vlan like this

vconfig add eth0 100
brctl addbr br1
brctl addif br1 eth0.100

If you later add a bridge (or bond) should the previous added bridge still work ? 
Yes I think so, for me it's the expected behaviour.

brctl addbr br0
brctl addif br0 eth0

Regards
Hans
