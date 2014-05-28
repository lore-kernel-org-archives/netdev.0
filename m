From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH] Add bridge ifindex to bridge fdb notify msgs
Date: Tue, 27 May 2014 17:05:49 -0700
Message-ID: <5385285D.4060106@cumulusnetworks.com>
References: <1401165586-13836-1-git-send-email-roopa@cumulusnetworks.com> <20140527093713.512824b0@nehalam.linuxnetplumber.net> <5384C5C6.2090606@cumulusnetworks.com> <538508D0.5050405@mojatatu.com> <53850A39.5060406@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:41803 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbaE1AFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 20:05:53 -0400
In-Reply-To: <53850A39.5060406@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal,

i hadn't looked at NDA_MASTER for set yet.
I was going to. We have some versions of patches for notify and dump 
which i was mainly focusing on.
Agree that it is not needed for sets and creates further confusion and 
possibly creates the same problems in userspace which i am trying to 
solve. So, ack on that.

I had a question regarding dump,
We can filter in kernel (as your patch does on the other thread) or in 
userspace based on master index with new filter arguments to iproute2 to 
determine the bridge and port for filtering. This follows the existing 
filtering support in all other cmds in iproute2. Which is great.

But, Is there any interest in adding master to the default iproute2 
bridge output ?. like the below ?
# bridge fdb show
44:38:39:00:27:ba dev bond2.2003 master br-2003 permanent
44:38:39:00:27:bb dev bond4.2003 master br-2003 permanent
44:38:39:00:27:bc dev bond2.2004 master br-2004 permanent

master can be put at the end of the output line for each fdb entry or 
make it optional with -d[etails].

(Don't intend to change output and break existing apps and i also 
understand that filtering by bridge/master name is a way to solve the 
problem. But i had a request from our internal team to post the 
question. So, just asking to see if there is interest to modify the 
default fdb show to include the master during display. It would make the 
default global fdb show cmd more complete).

Thanks,
Roopa



On 5/27/14, 2:57 PM, Jamal Hadi Salim wrote:
> Just to be clear - I meant i dont see its usefulness in a set
> (definitely useful in notify and get/dump).
>
> cheers,
> jamal
>
> On 05/27/14 17:51, Jamal Hadi Salim wrote:
>
>> I think it is useful for symettry purposes to have both directions
>> have NDA_MASTER; but other than that, I dont see any purpose NDA_MASTER
>> serves. A bridge port is specified on the ndm msg to the kernel.
>> A bridge port can only belong to one master.
>> The kernel can deduce that already.
>> Infact i think specifying the NDA_MASTER may cause problems when
>> the specified NDA_MASTER is not the bridge to which the bridge port
>> belongs to....
>>
>> cheers,
>> jamal
>>
>
