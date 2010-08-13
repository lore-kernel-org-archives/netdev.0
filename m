From: Steve Chen <schen@mvista.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Fri, 13 Aug 2010 17:25:27 -0500
Message-ID: <AANLkTik9=TcMWzNyKWYyDu+bbGscPne6++gD42aju9s_@mail.gmail.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
	<4C646330.6080303@hp.com>
	<AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
	<4C64ACB2.3090600@hp.com>
	<AANLkTi=01koVqt6YR0LQi53Nx0E=7UT1TFVNL44TwAR4@mail.gmail.com>
	<4C65870F.4080307@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:44386 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604Ab0HMWZ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 18:25:27 -0400
Received: by iwn7 with SMTP id 7so243497iwn.19
        for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 15:25:27 -0700 (PDT)
In-Reply-To: <4C65870F.4080307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 13, 2010 at 12:55 PM, Brian Haley <brian.haley@hp.com> wrot=
e:
> On 08/13/2010 01:34 PM, Steve Chen wrote:
>>>>>> The TAHI correspondent node tests CN-6-4-1 (Processing in upper =
layer
>>>>>> - Echo Checksum) failed for me in the 2.6.32 kernel. =A0It appea=
rs that
>>>>>> the Linux kernel is replying the ICMP echo request in
>>>>>> icmpv6_echo_reply without much checking. =A0Is this an intention=
al
>>>>>> non-conformance to RFC3775 section 9.3.1?
> [snip]
>
>> It appears that skb->ip_summed is always 1 (CHECKSUM_UNNECESSARY).
>> I'm using e1000e. =A0Looking at the driver, there is a checksum offl=
oad
>> hardware. =A0I think the code is doing frame check on the entire
>> Ethernet packet. =A0Since no error was found, it assume everything
>> inside is correct.
>
> # ethtool -K ethX rx off
>
> Does that help? =A0Does using a different NIC help?
>

ethtool did not help.

I tried to run the test with a different NIC, but I keep getting

=2E..

IPSEC_AKEY      :               --------------------
IPSEC_EALGO     :               ---------
IPSEC_EKEY      :               ------------------------
IPSEC_SUPPORT   :               OFF
RR_TIMEOUT      :               3
TIMEOUT :               2
WAIT_RATELIMIT  :               1
send Ra_R0_AllNd
Wait 3 sec.
Clear Captured Packets (Link0)
Clear Captured Packets (Link0)
send Ns_R0_AllNd
######### Packe Name(RH) Field Value(NextHeader) is NULL
CNT_SendAndRecv Status=3DUnKnown
NG UnKnown
  -> Initialization Fail
=2E..

I'm have not been able to locate problem...  Will continue to look Mond=
ay.

Steve
