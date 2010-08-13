From: Steve Chen <schen@mvista.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Fri, 13 Aug 2010 12:34:29 -0500
Message-ID: <AANLkTi=01koVqt6YR0LQi53Nx0E=7UT1TFVNL44TwAR4@mail.gmail.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
	<4C646330.6080303@hp.com>
	<AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
	<4C64ACB2.3090600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:56167 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404Ab0HMReb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 13:34:31 -0400
Received: by gwj17 with SMTP id 17so77272gwj.19
        for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 10:34:30 -0700 (PDT)
In-Reply-To: <4C64ACB2.3090600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 12, 2010 at 9:23 PM, Brian Haley <brian.haley@hp.com> wrote=
:
> On 08/12/2010 07:04 PM, Steve Chen wrote:
>> On Thu, Aug 12, 2010 at 4:10 PM, Brian Haley <brian.haley@hp.com> wr=
ote:
>>> Hi Steve,
>>>
>>> On 07/28/2010 11:20 PM, Steve Chen wrote:
>>>> Hello,
>>>>
>>>> The TAHI correspondent node tests CN-6-4-1 (Processing in upper la=
yer
>>>> - Echo Checksum) failed for me in the 2.6.32 kernel. =A0It appears=
 that
>>>> the Linux kernel is replying the ICMP echo request in
>>>> icmpv6_echo_reply without much checking. =A0Is this an intentional
>>>> non-conformance to RFC3775 section 9.3.1?
>>>
>>> Sorry for the late reply. =A0I've run these tests in the past again=
st
>>> SLES11 (2.6.27 ?) back in January 2009 and this one passed from loo=
king
>>> at my logs. =A0I don't have that system around anymore to check the=
 config,
>>> etc. =A0I didn't see any obvious commit that would have broken it f=
rom a
>>> quick look, do you have a test setup to do some debugging? =A0It wi=
ll
>>> take a little time for me to re-configure mine to run this test.
>>
>> Brian,
>>
>> I'm using mip6d from git://www.umip.org/git/umip.git commit id
>> d1c240f3deb690af902ce1ff128780551ff6141c. =A0Is that the correct ver=
sion
>> to use? =A0Looking at the kernel code again, the checksum error shou=
ld
>> have been caught in icmpv6_rcv. =A0There are probably something wron=
g
>> with my setup. =A0I'll dig around a bit more.
>
> The system has long since been dismantled, so I'm not sure what versi=
on
> of mip6d I used. =A0Yes, icmpv6_rcv() does check for checksum errors,=
 it
> would be good to print-out three addresses to see which one is which,
> in case they weren't swapped correctly or something. =A0It would be g=
ood
> to know what value skb->ip_summed was too, as a start.

It appears that skb->ip_summed is always 1 (CHECKSUM_UNNECESSARY).
I'm using e1000e.  Looking at the driver, there is a checksum offload
hardware.  I think the code is doing frame check on the entire
Ethernet packet.  Since no error was found, it assume everything
inside is correct.
>
>> Tests 5-3-1 to 5-3-6 also failed for me. =A0 Did they pass for you?
>
> I had no failures, but 5 warnings (2-1-6, 2-3-11, 4-7-1, 5-4-2, and
> 6-3-1). =A0I'll see if I can get a CN test run done on my current
> config.
>

All these tests passed without warnings for me.  However, I do see
warnings on 2-3-10-2 and 6-2-2 with my setup.

Steve
