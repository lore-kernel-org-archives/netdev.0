From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: L2 network namespace benchmarking (resend with Service Demand)
Date: Fri, 06 Apr 2007 13:19:36 +0200
Message-ID: <46162CC8.7080708@bull.net>
References: <460D1BBC.9090602@fr.ibm.com> <m1d52i9bfg.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40384 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766729AbXDFLTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 07:19:30 -0400
In-Reply-To: <m1d52i9bfg.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <dlezcano@fr.ibm.com> writes:
> 
>> Hi,
>>
>> as suggested Rick, I added the Service Demand results to the matrix.
> 
> A couple of random thoughts in trying to understand the numbers you are
> seeing.
> 
> - Checksum offloading?
> 
>   You have noted that with the bridge netfilter support disabled you
>   are still seeing additional checksum overhead.  Just like you are
>   seeing in the routing case.
> 
>   Is it possible the problem is simply that etun doesn't support
>   checksum offloading, while your normal test hardware does?

Looks like you are 100% correct.
I feel a bit stupid I didn't think about this "small" difference 
between real NIC and etun.

If I turn off checksum offloading on my physical NIC, the checksum 
"overhead" (load) measured by oprofile is about the same in both case: 
when running netperf through a real NIC or through an etun tunnel first.

Benjamin

> - Tagged VLANs?
>   
>   Currently you have tested bridging and routing to get the packets to
>   a network namespace.  Could you test tagged vlans?
> 
>   I'm just curious if we have anything in the network stack today that
>   will multiplex a NIC without measurable overhead.
> 
> - Without NETNS?
> 
>   We should probably see if we can setup the same configuration we are
>   testing without network namespaces (just multiple interfaces on the
>   same machine) and see if we can still measure the same overhead.
>   Just to confirm the overhead is not a network namespace related
>   thing.
> 
>   I know we can configure the same case with bridging and I am fairly
>   confident that we will see the same overhead without network
>   namespaces.
> 
>   Of the top of my head I am insufficiently clever to think how we
>   could configure the routing case without network namespaces,
>   although we might be able to force it and if so it would be
>   interesting to measure.
> 
> I will work to get the etun setup races fixed and to fix whatever
> obvious feature deficiencies it has (like no configurable MTU support)
> and see if I can get that pushed upstream.  That should make it easier
> for other people to reproduce what we are seeing.
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
