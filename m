From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Thu, 13 Oct 2011 20:23:22 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D90317A@ESESSCMS0356.eemea.ericsson.se>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab>
 <20111010223752.GB2373@minipsycho>
 <1318518274.9266.94.camel@sakura.staff.proxad.net>,<20111013153850.GA2031@minipsycho>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>,<4E972301.4030004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, Maxime Bizon <mbizon@freebox.fr>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:55486 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab1JMSXY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 14:23:24 -0400
In-Reply-To: <4E972301.4030004@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>On 10/13/2011 8:59 AM, Hans Schillstr=F6m wrote:
>> Thu, Oct 13, 2011 at 05:04:34PM CEST, mbizon@freebox.fr wrote:
>>>>
>>>> On Tue, 2011-10-11 at 00:37 +0200, Jiri Pirko wrote:
>>>>
>>>>> Hmm, I must look at this again tomorrow but I have strong feeling=
 this
>>>>> will break some some scenario including vlan-bridge-macvlan.
>>>>
>>>> unless I'm mistaken, today's behaviour:
>>>>
>>>> # vconfig add eth0 100
>>>> # brctl addbr br0
>>>> # brctl addif br0 eth0
>>>>
>>>> =3D> eth0.100 gets no more packets, br0.100 is to be used
>>>>
>>>> after the patch won't we get the opposite ?
>>>
>>> Looks like it. The question is what is the correct behaviour...
>>
>> I think this it become correct now, you should not destroy lover lev=
el if possible.
>> I.e. as John wrote "it's not an unexpected behaviour"
>>
>> Consider adding a bridge to a vlan like this
>>
>> vconfig add eth0 100
>> brctl addbr br1
>> brctl addif br1 eth0.100
>>
>> If you later add a bridge (or bond) should the previous added bridge=
 still work ?
>> Yes I think so, for me it's the expected behaviour.
>>
>> brctl addbr br0
>> brctl addif br0 eth0
>>
>
>Sorry I'm not entirely sure I followed the above two posts. Note
>this patch restores behavior that has existed for most of the
>2.6.x kernels. In the 3.x kernels VLAN100 is dropped in the
>schematic below (assuming eth0 is active), I think this is
>incorrect.
>
>      ---> eth0.100
>       |
>       |
>eth0 -----> br0
>
>With this patch VLAN100 is delivered to eth0.100 as I expect. Now
>adding a VLAN100 to br0.
>
>
>       ---> eth0.100
>       |
>       |
>eth0 -----> br0---> br0.100
>
>With this patch in the above case VLAN100 is delivered to the
>first matching vlan. Here eth0.100 will receive the packet If
>you really want br0.100 to receive the packet remove eth0.100.
>Without this patch the packet will be delivered to br0.100,
>but no configuration will allow a packet to be delivered to
>eth0.100 with a bond.
>
>The first schematic is used for doing bonding on LAN traffic
>and SAN (storage) traffic with MPIO. So I think my expectations
>are correct and have a real use case.
>
>Thanks,
>John

Sorry if I caused confusion,  I do agree with you to 100%.

Regards
Hans
