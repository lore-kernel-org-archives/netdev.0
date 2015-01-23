From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Fri, 23 Jan 2015 10:25:26 -0800
Message-ID: <CA+mtBx87bZBnY_9cgQ7k=xsD0VGZUt0rc9DjhSqhpeH3LZiuFw@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
	<CA+mtBx_z3trTkK2qnVboXv7sJNjMHLr9V+4A=aFqyMo_0p1_Eg@mail.gmail.com>
	<CAEP_g=-sVSwewV=7qAYQNtBRVSrUOAjNCpfwniNq_WPg2FVpFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:53141 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585AbbAWSZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 13:25:28 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so3402995igb.2
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 10:25:27 -0800 (PST)
In-Reply-To: <CAEP_g=-sVSwewV=7qAYQNtBRVSrUOAjNCpfwniNq_WPg2FVpFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2015 at 9:38 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Jan 23, 2015 at 8:58 AM, Tom Herbert <therbert@google.com> wrote:
>> On Tue, Jan 20, 2015 at 12:25 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>>> Following patch series adds support for Stateless Transport
>>> Tunneling protocol.
>>> STT uses TCP segmentation offload available in most of NIC. On
>>> packet xmit STT driver appends STT header along with TCP header
>>> to the packet. For GSO packet GSO parameters are set according
>>> to tunnel configuration and packet is handed over to networking
>>> stack. This allows use of segmentation offload available in NICs
>>>
>>> Netperf unidirectional test gives ~9.4 Gbits/s performance on 10Gbit
>>> NIC with 1500 byte MTU with two TCP streams.
>>>
>> The reason you're able to get 9.4 Gbit/s with an L2 encapsulation
>> using STT is that it has less protocol overhead per packet when doing
>> segmentation compared to VXLAN (without segmentation STT packets will
>> have more overhead than VXLAN).
>>
>> A VXLAN packet with TCP/IP has headers
>> IP|UDP|VXLAN|Ethernet|IP|TCP+options. Assuming TCP is stuffed with
>> options, this is 20+8+8+16+20+40=112 bytes, or 7.4% MTU. Each STT
>> segment created in GSO, other than the first, has just IP|TCP headers
>> which is 20+20=40 bytes or 2.6% MTU. So this explains throughput
>> differences between VXLAN and STT.
>
> Tom, what performance do you see with a single stream of VXLAN running
> on net-next with default configuration? The difference in numbers
> being posted here is greater than a few percent caused by protocol
> overheard.

Please look at the data I posted with the VXLAN RCO patches.

TCP/IP 10Gbps with 1500 byte MTU, 14 bytes for Ethernet header, 15
bytes for preamble, FCS, IPG, and no TCP options gives 9.54Gbps
maximum throughput. About what you see in STT minus overhead in first
segment.

TCP/IPv4 on VXLAN with TCP options gives max throughout 9.09Gbps,
TCP/IPv6 over VXLAN then gives 8.96Gbps. Pretty much what we see give
or take a few bytes for TCP options and rounding error.

Tom
