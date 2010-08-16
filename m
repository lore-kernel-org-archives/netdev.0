From: Steve Chen <schen@mvista.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Mon, 16 Aug 2010 09:07:29 -0500
Message-ID: <AANLkTi=qP7BO2=Uhx2Xb0XiLbUz0mPutbg0vz6QnMgYb@mail.gmail.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
	<4C646330.6080303@hp.com>
	<AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
	<4C64ACB2.3090600@hp.com>
	<AANLkTi=01koVqt6YR0LQi53Nx0E=7UT1TFVNL44TwAR4@mail.gmail.com>
	<4C65870F.4080307@hp.com>
	<AANLkTik9=TcMWzNyKWYyDu+bbGscPne6++gD42aju9s_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:43779 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372Ab0HPOHa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 10:07:30 -0400
Received: by iwn7 with SMTP id 7so1717347iwn.19
        for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 07:07:29 -0700 (PDT)
In-Reply-To: <AANLkTik9=TcMWzNyKWYyDu+bbGscPne6++gD42aju9s_@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 13, 2010 at 5:25 PM, Steve Chen <schen@mvista.com> wrote:
> On Fri, Aug 13, 2010 at 12:55 PM, Brian Haley <brian.haley@hp.com> wr=
ote:
>> On 08/13/2010 01:34 PM, Steve Chen wrote:
>>>>>>> The TAHI correspondent node tests CN-6-4-1 (Processing in upper=
 layer
>>>>>>> - Echo Checksum) failed for me in the 2.6.32 kernel. =A0It appe=
ars that
>>>>>>> the Linux kernel is replying the ICMP echo request in
>>>>>>> icmpv6_echo_reply without much checking. =A0Is this an intentio=
nal
>>>>>>> non-conformance to RFC3775 section 9.3.1?
>> [snip]
>>
>>> It appears that skb->ip_summed is always 1 (CHECKSUM_UNNECESSARY).
>>> I'm using e1000e. =A0Looking at the driver, there is a checksum off=
load
>>> hardware. =A0I think the code is doing frame check on the entire
>>> Ethernet packet. =A0Since no error was found, it assume everything
>>> inside is correct.
>>
>> # ethtool -K ethX rx off
>>
>> Does that help? =A0Does using a different NIC help?
>>
>
> ethtool did not help.
>
> I tried to run the test with a different NIC, but I keep getting
>
> ...
>
> IPSEC_AKEY =A0 =A0 =A0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 -----------------=
---
> IPSEC_EALGO =A0 =A0 : =A0 =A0 =A0 =A0 =A0 =A0 =A0 ---------
> IPSEC_EKEY =A0 =A0 =A0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 -----------------=
-------
> IPSEC_SUPPORT =A0 : =A0 =A0 =A0 =A0 =A0 =A0 =A0 OFF
> RR_TIMEOUT =A0 =A0 =A0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 3
> TIMEOUT : =A0 =A0 =A0 =A0 =A0 =A0 =A0 2
> WAIT_RATELIMIT =A0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 1
> send Ra_R0_AllNd
> Wait 3 sec.
> Clear Captured Packets (Link0)
> Clear Captured Packets (Link0)
> send Ns_R0_AllNd
> ######### Packe Name(RH) Field Value(NextHeader) is NULL
> CNT_SendAndRecv Status=3DUnKnown
> NG UnKnown
> =A0-> Initialization Fail
> ...

Brian,

Oops, set the Link0 in nut.def to the wrong value.  However, I'm still
getting the same failure with different NIC.  I'll start looking into
the code.  Please let me know your test results.

Thanks,

Steve
