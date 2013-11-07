From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Using HTB over MultiQ
Date: Thu, 07 Nov 2013 07:06:54 -0800
Message-ID: <527BAC8E.1090005@intel.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>   <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>  <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>  <527BA63F.7040900@intel.com> <1383836068.9412.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42785 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862Ab3KGPHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 10:07:19 -0500
In-Reply-To: <1383836068.9412.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/2013 6:54 AM, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 06:39 -0800, John Fastabend wrote:
>
>>
>> With the multiq qdisc you could attach filter to the root qdisc and use
>> skbedit to set the queue_mapping field,
>>
>> #tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
>> 	match ip dst 192.168.0.3 \
>> 	action skbedit queue_mapping 3
>>
>
> Oh right, this is the way ;)
>
> I wonder if we can have 'action skbedit rxhash 34' ?
>

Sure, it should easy enough.

>
>> if you configure the filters to map to the correct classes this would
>> work.
>>
>> Or another way would be use mqprio and steer packets to HTB classes
>> using the skb->priority. The priority can be set by iptables/nftables
>> or an ingress filter.
>
> Yes, but this might duplicate the 'customer' tree Anton has to put on
> the filters anyway ?
>

hmm not sure I understand. As long as customer flows are mapped to the
correct HTB qdisc via skb priority with the correct htb child classes
what would be duplicated?
