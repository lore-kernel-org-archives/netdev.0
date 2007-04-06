From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: L2 network namespace benchmarking (resend with Service Demand)
Date: Fri, 06 Apr 2007 08:25:48 -0600
Message-ID: <m1veg98tqr.fsf@ebiederm.dsl.xmission.com>
References: <460D1BBC.9090602@fr.ibm.com>
	<m1d52i9bfg.fsf@ebiederm.dsl.xmission.com> <46162CC8.7080708@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34602 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767660AbXDFO0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 10:26:32 -0400
In-Reply-To: <46162CC8.7080708@bull.net> (Benjamin Thery's message of "Fri, 06
	Apr 2007 13:19:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Thery <benjamin.thery@bull.net> writes:

> Eric W. Biederman wrote:

>> A couple of random thoughts in trying to understand the numbers you are
>> seeing.
>>
>> - Checksum offloading?
>>
>>   You have noted that with the bridge netfilter support disabled you
>>   are still seeing additional checksum overhead.  Just like you are
>>   seeing in the routing case.
>>
>>   Is it possible the problem is simply that etun doesn't support
>>   checksum offloading, while your normal test hardware does?
>
> Looks like you are 100% correct.
> I feel a bit stupid I didn't think about this "small" difference between real
> NIC and etun.
>
> If I turn off checksum offloading on my physical NIC, the checksum "overhead"
> (load) measured by oprofile is about the same in both case: when running netperf
> through a real NIC or through an etun tunnel first.

Interesting.  You can also 'enable' checksum offloading when using etun with
ethtool.  Which should just tell the kernel not to do checksumming.  A
bad idea in general but it might be useful in confirming where the
performance overhead is coming from, and when used with routing I
believe it is safe.  When used with bridging I don't know.

Thinking about it the ideal situation is to preserve skb->ip_summed it
if came from another device, instead of unconditionally setting it.
I need to take a good hard look at etun_xmit and make certain we
are dotting all of the i's and crossing all of the t's for best
performance and compatibility with the rest of the network stack.

Eric
