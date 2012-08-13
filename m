From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Mon, 13 Aug 2012 09:08:35 -0700
Message-ID: <ceb0d636-74a3-4d6d-86de-84e8970dd8ec@email.android.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com> <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com> <877gt415lu.fsf@xmission.com> <5028BBCE.4020908@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "Michael S. Tsirkin" <mst@redhat.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51111 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab2HMQI4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 12:08:56 -0400
In-Reply-To: <5028BBCE.4020908@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@mellanox.com> wrote:

>On 12/08/2012 18:40, Eric W. Biederman wrote:
>> Let me give you a non-hack recomendation.
>>
>> - Give up on being wire compatible with IPoIB.
>>
>> - Define and implement ethernet over inifiniband aka EoIB.
>>
>> With EoIB:
>> - The SM would map ethernet address to inifiniband hardware
>addresses.
>> - You discover which multicast addresses are of interest from the
>>    IP layer above so no snooping is necessary.
>> - You could run queue pairs directly to hosts.
>>
>> Shrug.  It is trivial and it will work.  It will probably run into
>the
>> same problems that have historically been a problem for using IPoIB
>> (lack of stateless offloads) but shrug that is mostly a NIC firmware
>> problem.  The switches will have no trouble and interoperability will
>> be assured.
>>
>> If you want to map ethernet over infiniband please map ethernet over
>> infiniband.  Don't poorly NAT ethernet into infiniband.
>>
>>
>
>
>EoIB is a valid suggestion and we will look into it as well, BUT:
>
>Providing EoIB is a separate discussion, obviously defining and 
>standardizing a new protocol takes what is takes (a lot of time,
>longish 
>term effort), and will also take time to develop/debug/mature e.g as

If you follow Michael Tirskins suggestion and use the same wire encoding as IPoIB and infer the mac address from the lids and queue pair numbers as you are already doing with for eIPoIB, except for defining exactly how to get the subnet manager to store the mac address to lid/qpn mapping you are done.

If you don't involve a comitte and simply define a defacto standard it will take less effort than this conversation and less effort than implementing your eIPoIB driver.


>you 
>mentioned, some of the features/offloads might require new NIC HW, etc 
>-- compared to IPoIB which is here for many years

So deploy routing and proxy arp and you are done.

>In practice there is already a huge install base for IPoIB software and
>
>hardware products, in different operating environments/OS. We can't
>just 
>through away everything and tell people to replace it all with a new 
>protocol, e.g. bridging devices, storage systems/appliances, VMware, 
>Windows, .. systems in production environments --- so
>the interoperability concern you've mentioned gonna hit very hard.

There is no need to throw anything away.  Just put them on different IP subnets.

Shrug.

>The eIPoIB driver comes to provide a way to work with IPoIB in 
>virtualized environments, where still, the suggestions/concerns raised 
>in this thread should be addressed.

eIPoIB does not work.

I can't get an IP address with out a specially configured dhcp server, and special dhcp clients.

eIPoIB does not work with IPv6.

As David Miller already said this code has no chance of being merged.

Shrug.  I have been polite and pointed out implementation choices that actually work.  Solutions that are less effort and less code, and provide more interoperability.

If after patient explanation you can not appreciate why people consider eIPoIB to be totally unacceptable that is your problem.

Good luck in your future endeavours,

Eric
