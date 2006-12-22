From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected
 on CPU#0!)
Date: Fri, 22 Dec 2006 06:05:18 -0800
Message-ID: <458BE61E.9030004@candelatech.com>
References: <45889C53.8000307@candelatech.com> <20061222071308.GA1791@ff.dom.local> <20061222074209.GA2148@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57044 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422999AbWLVOF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Dec 2006 09:05:27 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061222074209.GA2148@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Fri, Dec 22, 2006 at 08:13:08AM +0100, Jarek Poplawski wrote:
>> On 20-12-2006 03:13, Ben Greear wrote:
>>> This is from 2.6.18.2 kernel with my patch set.  The MAC-VLANs are in 
>>> active use.
>>>  From the backtrace, I am thinking this might be a generic problem, 
>>> however.
>>>
>>> Any ideas about what this could be?  It seems to be reproducible every 
>>> day or
> ...
>> If it doesn't help, I hope lockdep will be more
>> precise when you'll upgrade to 2.6.19 or higher.
> 
> ... or when you enable lockdep in 2.6.18 (I've
> forgotten it's there alredy!).

I got lucky..the system was available by ssh still.  I see this in the boot logs..I assume
this means lockdep is enabled?  Should I have expected to see a lockdep trace in the case of
his soft-lockup then?

.....
Dec 19 04:33:48 localhost kernel: Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo MolnarDec 19 04:33:48 localhost kernel: ... 
MAX_LOCKDEP_SUBCLASSES:    8
Dec 19 04:33:48 localhost kernel: ... MAX_LOCK_DEPTH:          30
Dec 19 04:33:48 localhost kernel: ... MAX_LOCKDEP_KEYS:        2048
Dec 19 04:33:48 localhost kernel: ... CLASSHASH_SIZE:           1024
Dec 19 04:33:48 localhost kernel: ... MAX_LOCKDEP_ENTRIES:     8192
Dec 19 04:33:48 localhost kernel: ... MAX_LOCKDEP_CHAINS:      8192
Dec 19 04:33:48 localhost kernel: ... CHAINHASH_SIZE:          4096
Dec 19 04:33:48 localhost kernel:  memory used by lock dependency info: 696 kB
Dec 19 04:33:48 localhost kernel:  per task-struct memory footprint: 1200 bytes
Dec 19 04:33:48 localhost kernel: ------------------------
Dec 19 04:33:48 localhost kernel: | Locking API testsuite:
....


> 
> Jarek P.


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

