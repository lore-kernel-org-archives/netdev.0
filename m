From: Brian Haley <brian.haley@hp.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Thu, 12 Aug 2010 22:23:46 -0400
Message-ID: <4C64ACB2.3090600@hp.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>	<4C646330.6080303@hp.com> <AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:11625 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755296Ab0HMCXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 22:23:49 -0400
In-Reply-To: <AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2010 07:04 PM, Steve Chen wrote:
> On Thu, Aug 12, 2010 at 4:10 PM, Brian Haley <brian.haley@hp.com> wrote:
>> Hi Steve,
>>
>> On 07/28/2010 11:20 PM, Steve Chen wrote:
>>> Hello,
>>>
>>> The TAHI correspondent node tests CN-6-4-1 (Processing in upper layer
>>> - Echo Checksum) failed for me in the 2.6.32 kernel.  It appears that
>>> the Linux kernel is replying the ICMP echo request in
>>> icmpv6_echo_reply without much checking.  Is this an intentional
>>> non-conformance to RFC3775 section 9.3.1?
>>
>> Sorry for the late reply.  I've run these tests in the past against
>> SLES11 (2.6.27 ?) back in January 2009 and this one passed from looking
>> at my logs.  I don't have that system around anymore to check the config,
>> etc.  I didn't see any obvious commit that would have broken it from a
>> quick look, do you have a test setup to do some debugging?  It will
>> take a little time for me to re-configure mine to run this test.
> 
> Brian,
> 
> I'm using mip6d from git://www.umip.org/git/umip.git commit id
> d1c240f3deb690af902ce1ff128780551ff6141c.  Is that the correct version
> to use?  Looking at the kernel code again, the checksum error should
> have been caught in icmpv6_rcv.  There are probably something wrong
> with my setup.  I'll dig around a bit more.

The system has long since been dismantled, so I'm not sure what version
of mip6d I used.  Yes, icmpv6_rcv() does check for checksum errors, it
would be good to print-out three addresses to see which one is which,
in case they weren't swapped correctly or something.  It would be good
to know what value skb->ip_summed was too, as a start.

> Tests 5-3-1 to 5-3-6 also failed for me.   Did they pass for you?

I had no failures, but 5 warnings (2-1-6, 2-3-11, 4-7-1, 5-4-2, and
6-3-1).  I'll see if I can get a CN test run done on my current
config.

-Brian
