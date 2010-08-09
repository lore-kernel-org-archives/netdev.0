From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Mon, 09 Aug 2010 10:44:14 -0700
Message-ID: <4C603E6E.1060309@candelatech.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org> <20091029233848.GV3141@kvack.org> <4C603999.1030801@candelatech.com> <20100809173429.GR30010@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34098 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab0HIRoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 13:44:17 -0400
In-Reply-To: <20100809173429.GR30010@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2010 10:34 AM, Benjamin LaHaise wrote:
> Hello Ben,
>
> On Mon, Aug 09, 2010 at 10:23:37AM -0700, Ben Greear wrote:
>> I was just comparing my out-of-tree patch set to .35, and it appears
>> little or none of the patches discussed in this thread are in the
>> upstream kernel yet.
>
> I was waiting on Eric's sysfs changes for namespaces to settle down, but
> ended up getting busy on other things.  I guess now is a good time to pick
> this back up and try to merge my changes for improving interface scaling.
> I'll send out a new version of the patches sometime in the next couple of
> days.  I'm also about to make a new Babylon release as well, I just need
> to write some more documentation. :-/
>
> Btw, one thing I noticed but haven't been able to come up with a fix for
> yet is that iptables has scaling issues with lots of interfaces.
> Specifically, we had to start adding one iptables rule per interface for smtp
> filtering (not all subscribers are permitted to send smtp directly out to
> the net, so it has to be per-interface).  It seems that those all get
> dumped into a giant list.  What I'd like to do is to be able to attach rules
> directly to the interface, but I haven't really had the time to do a mergable
> set of changes for that.  Thoughts anyone?

We also have a few rules per interface, and notice that it takes around 10ms
per rule when we are removing them, even when using batching in 'ip':

This is on a high-end core i7, otherwise lightly loaded.

Total IPv4 rule listings: 2097
Cleaning 2094 rules with ip -batch...
time -p ip -4 -force -batch /tmp/crr_batch_cmds_4.txt
real 17.81
user 0.05
sys 0.00


Patrick thought had an idea, but I don't think he had time to
look at it further:

"Its probably the synchronize_rcu() in fib_nl_delrule() and
the route flushing happening after rule removal."


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

