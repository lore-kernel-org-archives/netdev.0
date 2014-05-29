From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] bridge: Add master device name to bridge fdb
 show
Date: Wed, 28 May 2014 18:53:36 -0700
Message-ID: <53869320.6010302@cumulusnetworks.com>
References: <1401255611-30862-1-git-send-email-roopa@cumulusnetworks.com> <53864051.4070102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, jhs@mojatatu.com, wkok@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, shm@cumulusnetworks.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:52375 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbaE2Bxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 21:53:42 -0400
In-Reply-To: <53864051.4070102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/28/14, 1:00 PM, Vlad Yasevich wrote:
> On 05/28/2014 01:40 AM, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> (This patch depends on net-next patch titled
>> "Add bridge ifindex to bridge fdb notify msgs")
>>
>> This patch adds master dev name from NDA_MASTER netlink attribute
>>   to bridge fdb show output
>>
>> current iproute2 tries to print 'master' in the output if NTF_MASTER
>> is present. But, kernel today does not set NTF_MASTER during dump
>> requests. Which means I have not seen iproute2 bridge cmd print 'master' atall.
>> This patch overrides the NTF_MASTER flag if NDA_MASTER attribute is present.
>>
>> Example output:
>>
>> before this patch:
>> # bridge fdb show
>> 44:38:39:00:27:ba dev bond2.2003 permanent
>> 44:38:39:00:27:bb dev bond4.2003 permanent
>> 44:38:39:00:27:bc dev bond2.2004 permanent
>>
>> After this patch:
>> # bridge fdb show
>> 44:38:39:00:27:ba dev bond2.2003 master br-2003 permanent
>> 44:38:39:00:27:bb dev bond4.2003 master br-2003 permanent
>> 44:38:39:00:27:bc dev bond2.2004 master br-2004 permanent
> 'master' is already a reserved word in the bridge command and
> has a slightly different connotation. May be replace it with
> 'bridge' or something similar.
I am not so convinced about the 'bridge' keyword. The way i see it is: I 
am just adding more context to the existing 'master' keyword. In the 
cases i am pointing out above 'master' is a bridge.
If the only argument is that it changes existing output, ...i agree. I 
have expressed slight concerns about that before.
>
>> For comparision with the above, below is the output for NTF_SELF today,
>> # bridge fdb show
>> 33:33:00:00:00:01 dev eth0 self permanent
>> 01:00:5e:00:00:01 dev eth0 self permanent
>> 33:33:ff:00:01:cc dev eth0 self permanent
>>
>> If change in output is a concern, 'master' can be put at the end of the fdb
>> output line or made optional with -d[etails] option.
> As Stephen always mentions, iproute commands have to be invertable.
> In other words, what you get out of the show command you should
> be able to feed back into a set command.
>
> As such, it would probably be a good thing to support
> bridge fdb set 44:38:39:00:27:ba dev bond2.2003 bridge br-2003 permanent
We did discuss this on the other thread (RFC), and it does not seem 
necessary.
two things:
- like i indicated above, introducing 'bridge' to mean  'master' seems 
to add more confusion and
seems redundant. But, maybe that's just me.
- having user specify master when kernel can derive it
seems unnecessary (agree that for code symmetry we could add master 
during sets but make it optional)

>
> and I think this ends up being something very close to what
> Jamal already proposed.
>
> May be work together and come up with a single syntax.
Ack.
looking at jamals patch for fdb show filters,  if i consider my approach 
of using 'master' to represent a bridge,
his syntax would look like,

bridge fdb {show} [dev DEV]
bridge fdb {show} [dev DEV] [master BRDEV]

Thanks,
Roopa
