From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: L2 network namespace benchmarking
Date: Wed, 28 Mar 2007 09:07:56 +0200
Message-ID: <460A144C.7070800@fr.ibm.com>
References: <460997C2.4030902@fr.ibm.com> <20070327230827.GA22649@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Dmitry Mishin <dim@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Herbert Poetzl <herbert@13thfloor.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:52574 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964844AbXC1GwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 02:52:04 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l2S6q0ta065478
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 06:52:00 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2S6q03b2187506
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 07:52:00 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2S6pxxM008463
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 07:52:00 +0100
In-Reply-To: <20070327230827.GA22649@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl wrote:
> On Wed, Mar 28, 2007 at 12:16:34AM +0200, Daniel Lezcano wrote:
>> Hi,

[ cut ]

>> 3. General observations
>> -----------------------
>>
>> The objective to have no performances degrations, when the network
>> namespace is off in the kernel, is reached in both solutions.
>>
>> When the network is used outside the container and the network
>> namespace are compiled in, there is no performance degradations.
>>
>> Eric's patchset allows to move network devices between namespaces and
>> this is clearly a good feature, missing in the Dmitry's patchset. This
>> feature helps us to see that the network namespace code does not add
>> overhead when using directly the physical network device into the
>> container.
>>
>> The loss of performances is very noticeable inside the container and
>> seems to be directly related to the usage of the pair device and the
>> specific network configuration needed for the container. When the
>> packets are sent by the container, the mac address is for the pair
>> device but the IP address is not owned by the host. That directly
>> implies to have the host to act as a router and the packets to be
>> forwarded. That adds a lot of overhead.
>>
>> A hack has been made in the ip_forward function to avoid useless
>> skb_cow when using the pair device/tunnel device and the overhead
>> is reduced by the half.
> 
> would it be possible to do some tests regarding scalability?
> 
> i.e. I would be interested how the following would look like:
> 
>  10 connections on a single host (in parallel, overall performance)
>  10 connections from the same net space
>  10 connections from 10 different net spaces 
>     (i.e. one connection from each space)
> 
> we can assume that L3 isolation will give similar results to
> the first case, but if needed, we can provide a patch to
> test this too ...
> 

Ok. Assuming, Eric's and Dmitry's patchset are very similar, I will 
focus on the Eric's patchset because it is more mature and more easy to 
setup. I will have a look on the bridge optimization before doing that.

> 
> PS: great work! tx!
> 

Thanks.
