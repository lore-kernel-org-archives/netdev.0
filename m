From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Thu, 01 Apr 2010 08:19:43 +0100
Message-ID: <4BB4490F.8090406@katalix.com>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>	<20100330161746.9628.40723.stgit@bert.katalix.com>	<20100330092914.4f3e9ed3@nehalam>	<4BB2FD0D.1080105@katalix.com> <20100331160811.16351eb7@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:57280 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753348Ab0DAHUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 03:20:05 -0400
In-Reply-To: <20100331160811.16351eb7@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 31 Mar 2010 08:43:09 +0100
> James Chapman <jchapman@katalix.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> On Tue, 30 Mar 2010 17:17:46 +0100
>>> James Chapman <jchapman@katalix.com> wrote:
>>>
>>>> When dumping L2TP PPP sessions using /proc/net/l2tp, get
>>>> the assigned PPP device name from PPP using ppp_dev_name().
>>>>
>>>> Signed-off-by: James Chapman <jchapman@katalix.com>
>>>> Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
>>>>
>>> Why is this a necessary API?
>>> Why not put it in debugfs if just a debugging tool?
>> With the original driver (merged in 2.6.23), some people use horrible
>> hacks in scripts to derive info about their L2TP connections from /proc.
>> So I was reluctant to move it to debugfs in the new driver. If it is ok
>> to move an existing /proc file to debugfs, I'm happy to do so. People
>> should obtain such info from their L2TP userspace daemon, or through
>> netlink anyway.
>>
>>
> Sounds like a good use of sysfs either with attribute or symlink
> back to underlying device
> 
There might be thousands of L2TP sessions in some setups. Populating
sysfs with a link for each of those sessions isn't practical. The
existing /proc file dumps its info as a single text file for this
reason. I'd also like to provide the device name in the session netlink
message, which is the interface used by l2tp userspace, so I need a
kernel API to retrieve the device name from ppp.

I like the suggestion of using debugfs for access to driver debug info
though. I propose leaving the /proc file for L2TPv2 only, removing the
L2TPv3 data that I added to the proc file in this patch series, to
retain compatibility with the existing driver. This would show only
L2TPv2 sessions and tunnels. For new driver functionality (L2TPv3 etc),
use debugfs. The debugfs files would dump lists in a similar form to the
current code, listing all tunnels (L2TPv2 and L2TPv3) in a single file.
Using debugfs gives more flexibility for adding additional info later,
as required. How does that sound?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

