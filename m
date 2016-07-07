From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [iproute PATCHv2 0/2] Netns performance improvements
Date: Thu, 07 Jul 2016 00:09:33 -0500
Message-ID: <87r3b63ugi.fsf@x220.int.ebiederm.org>
References: <1467730280-17493-1-git-send-email-phil@nwl.cc>
	<20160706212257.4e35d0fb@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59311 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbcGGFWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:22:08 -0400
In-Reply-To: <20160706212257.4e35d0fb@xeon-e3> (Stephen Hemminger's message of
	"Wed, 6 Jul 2016 21:22:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Tue,  5 Jul 2016 16:51:18 +0200
> Phil Sutter <phil@nwl.cc> wrote:
>
>> Stress-testing OpenStack Neutron revealed poor performance of 'ip netns'
>> when dealing with a high amount of namespaces. The cause of this lies in
>> the combination of how iproute2 mounts NETNS_RUN_DIR and the netns files
>> therein and the fact that systemd makes all mount points of the system
>> shared.
>> 
>> Changes since v1:
>> - Added Suggested-by tag to patches.
>> 
>> Phil Sutter (2):
>>   ipnetns: Move NETNS_RUN_DIR into it's own propagation group
>>   ipnetns: Make netns mount points private
>> 
>>  ip/ipnetns.c | 12 +++++++++++-
>>  1 file changed, 11 insertions(+), 1 deletion(-)
>> 
>
> I want an ack for Eric on this, it seems a little risky

If I have read the tea leaves properly the first patch is fighting
a system configuration of "mount --rbind /run /var/run" which seems
inappropriate.  A symlink is likely a better fix.

The effect of the second patch is probably better had by performing the
optimization in the kernel, so everyone gets the benefit.

I am persuadable to change this behavior.  But if all we are doing is
optimization and not intentionally changing the semantics there appear
to be better places for the optimizations to happen.

Eric
