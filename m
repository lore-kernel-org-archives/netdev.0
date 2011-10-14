From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under bond
Date: Thu, 13 Oct 2011 17:22:02 -0700
Message-ID: <CAEP_g=9dk_ERdnw4Hw_8RO8Z23E1g2Q9G=AxPkiaVhwbHvo47A@mail.gmail.com>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab>
 <20111010223752.GB2373@minipsycho> <1318518274.9266.94.camel@sakura.staff.proxad.net>
 <20111013153850.GA2031@minipsycho> <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>
 <4E972301.4030004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Hans_Schillstr=C3=B6m?= <hans.schillstrom@ericsson.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:39936 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab1JNAWX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 20:22:23 -0400
Received: by vcge1 with SMTP id e1so109644vcg.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 17:22:22 -0700 (PDT)
In-Reply-To: <4E972301.4030004@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/13 John Fastabend <john.r.fastabend@intel.com>:
> On 10/13/2011 8:59 AM, Hans Schillstr=C3=B6m wrote:
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
>> Regards
>> Hans
>>
>>
>
> Sorry I'm not entirely sure I followed the above two posts. Note
> this patch restores behavior that has existed for most of the
> 2.6.x kernels. In the 3.x kernels VLAN100 is dropped in the
> schematic below (assuming eth0 is active), I think this is
> incorrect.

Actually, for most of 2.6.x the behavior was somewhat
non-deterministic since it depended on kernel version and the NIC.  As
a result, I think we can safely say that this wasn't a particularly
firm interface that we have to be wedded to.  Based on overwhelming
feedback, I think the interface in this patch is the preferred one and
what we should stabilize on.
