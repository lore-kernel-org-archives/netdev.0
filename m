From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH] vhost: Make it more scalable by creating a vhost	thread
 per device.
Date: Tue, 06 Apr 2010 21:49:17 +0300
Message-ID: <4BBB822D.7050400@redhat.com>
References: <1270229480.13897.8.camel@w-sridhar.beaverton.ibm.com>	 <20100404111433.GD3189@redhat.com> <1270488911.27874.43.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Tom Lendacky <toml@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757428Ab0DFStW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 14:49:22 -0400
In-Reply-To: <1270488911.27874.43.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/05/2010 08:35 PM, Sridhar Samudrala wrote:
> On Sun, 2010-04-04 at 14:14 +0300, Michael S. Tsirkin wrote:
>    
>> On Fri, Apr 02, 2010 at 10:31:20AM -0700, Sridhar Samudrala wrote:
>>      
>>> Make vhost scalable by creating a separate vhost thread per vhost
>>> device. This provides better scaling across multiple guests and with
>>> multiple interfaces in a guest.
>>>        
>> Thanks for looking into this. An alternative approach is
>> to simply replace create_singlethread_workqueue with
>> create_workqueue which would get us a thread per host CPU.
>>
>> It seems that in theory this should be the optimal approach
>> wrt CPU locality, however, in practice a single thread
>> seems to get better numbers. I have a TODO to investigate this.
>> Could you try looking into this?
>>      
> Yes. I tried using create_workqueue(), but the results were not good
> atleast when the number of guest interfaces is less than the number
> of CPUs. I didn't try more than 8 guests.
> Creating a separate thread per guest interface seems to be more
> scalable based on the testing i have done so far.
>    

Thread per guest is also easier to account.  I'm worried about guests 
impacting other guests' performance outside scheduler control by 
extensive use of vhost.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

