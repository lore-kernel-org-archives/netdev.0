From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 18:17:12 +0200
Message-ID: <4CAF4408.6070001@free.fr>
References: <201010071048.12817.hans.schillstrom@ericsson.com> <4CAEFE2C.3010007@free.fr> <201010081353.28056.hans.schillstrom@ericsson.com> <201010081428.37639.hans.schillstrom@ericsson.com> <4CAF3E78.8030202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:48993 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683Ab0JHQRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:17:18 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o98GHGeF031964
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 16:17:16 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o98GHHTC3903630
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 17:17:17 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o98GHGvf004352
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 17:17:16 +0100
In-Reply-To: <4CAF3E78.8030202@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2010 05:53 PM, Daniel Lezcano wrote:
> On 10/08/2010 02:28 PM, Hans Schillstrom wrote:
>> Hi Eric,
>> Any advice how to trace this down ?
>> This rollback_registered_many() seems to have on the lists before...
>> All IPv4 and IPv6 tunnels causes this crash, all you have to do is
>> load the tunnel module(s)
>> enter a new ns and exit from it.
>>
>> Have not tested any more devices than tunnels,
>> I did an "ip link delete" on my macvlans before exiting the ns.
>
> Ah ! I succeed to reproduce it.
> It does not appear immediately in fact.
>
> I am trying to simplify the configuration but I am falling in the bug I
> talked about in the previous email.

Ok, so after investigating, we just need a macvlan and specify an ipv6 
address for it (inside a new netns of course), and the loopback is not 
released. I compiled out the tunnels, so they are not related to this 
problem I think.

That reduces the scope of investigation :)

Looking forward ...

   -- Daniel
