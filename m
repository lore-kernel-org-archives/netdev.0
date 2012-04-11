From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [net-next PATCH v1 7/7] macvlan: add FDB bridge ops and new macvlan
 mode
Date: Tue, 10 Apr 2012 17:46:42 -0700
Message-ID: <4F84D472.8090602@us.ibm.com>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab> <20120409220053.3288.40867.stgit@jf-dev1-dcblab> <20120410080916.GB26540@redhat.com> <4F843544.8060209@intel.com> <20120410134321.GB18899@redhat.com> <4F8442F6.5070707@intel.com> <20120410143500.GD19556@redhat.com> <4F84511D.7060902@intel.com> <20120410153014.GA20488@redhat.com> <4F845345.8090601@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, roprabhu@cisco.com,
	stephen.hemminger@vyatta.com, davem@davemloft.net, hadi@cyberus.ca,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:53378 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab2DKArk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 20:47:40 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Tue, 10 Apr 2012 18:47:39 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 58CF8C90060
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 20:46:42 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3B0kh7M280572
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 20:46:43 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3B6HYvw009969
	for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 02:17:35 -0400
In-Reply-To: <4F845345.8090601@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/2012 8:35 AM, John Fastabend wrote:
> On 4/10/2012 8:30 AM, Michael S. Tsirkin wrote:
>> On Tue, Apr 10, 2012 at 08:26:21AM -0700, John Fastabend wrote:
>>> On 4/10/2012 7:35 AM, Michael S. Tsirkin wrote:
>>>> On Tue, Apr 10, 2012 at 07:25:58AM -0700, John Fastabend wrote:
>>>>>> Hmm okay, but this would mean we should convert
>>>>>> MACVLAN_MODE_PASSTHRU_NOPROMISC to something
>>>>>> that can combined with all modes. E.g.
>>>>>> MACVLAN_MODE_BRIDGE | MACVLAN_MODE_FLAG_XXXXX
>>>>>>
>>>>>> and document that it does not promise to flood
>>>>>> multicast.
>>>>>>
>>>>> How about changing MACVLAN_MODE_PASSTHRU_NOPROMISC ->  MACVLAN_MODE_NOPORMISC
>>>>> for this patch. Then a follow on series can rework bridge
>>>>> and VEPA to use it as well.
>>>> Right. We probably need a better name if it's going to
>>>> affect other things besides promisc though.
>>>>
>>> how about MACVLAN_MODE_FDBFLAG?
>> The idea being that no one figures out what this means so
>> no one will make any wrong assumptions? ;)
>>
> Well its a flag to enable the FDB (forwarding database) ops
> and skip dev_set_promisc() on passthru mode. Any better ideas?
> Maybe MACVLAN_MODE_FDBENABLE or MACVLAN_MODE_MANAGE_FDB?
Do we need to introduce another mode? I think this patch is enabling 
passthru mode without the need
to put the underlying device in promiscuous mode. So basically we can 
consider this patch as
an optimization.

Thanks
Sridhar
