From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v2 0/6] net: Add STT support.
Date: Thu, 29 Jan 2015 19:46:17 -0800
Message-ID: <54CAFE89.4090509@gmail.com>
References: <1422574156-1831-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:44805 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbbA3DqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 22:46:19 -0500
Received: by mail-pa0-f50.google.com with SMTP id rd3so46937975pab.9
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 19:46:18 -0800 (PST)
In-Reply-To: <1422574156-1831-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2015 03:29 PM, Pravin B Shelar wrote:
> Following patch series adds support for Stateless Transport
> Tunneling protocol.
> STT uses TCP segmentation offload available in most of NIC. On
> packet xmit STT driver appends STT header along with TCP header
> to the packet. For GSO packet GSO parameters are set according
> to tunnel configuration and packet is handed over to networking
> stack. This allows use of segmentation offload available in NICs
>
> The protocol is documented at
> http://www.ietf.org/archive/id/draft-davie-stt-06.txt
>
> I will send out OVS userspace patch on ovs-dev mailing list.
>
> Following are test results. All tests are done on net-next with
> STT and VXLAN kernel device without OVS.
>
> Single Netperf session:
> =======================
> VXLAN:
>     CPU utilization
>      - Send local: 1.26
>      - Recv remote: 8.62
>     Throughput: 4.9 Gbit/sec
> STT:
>     CPU utilization
>      - Send local: 1.01
>      - Recv remote: 1.8
>     Throughput: 9.45 Gbit/sec
>
> Five Netperf sessions:
> ======================
> VXLAN:
>     CPU utilization
>      - Send local: 9.7
>      - Recv remote: 70 (varies from 60 to 80)
>     Throughput: 9.05 Gbit/sec
> STT:
>     CPU utilization
>      - Send local: 5.85
>      - Recv remote: 14
>     Throughput: 9.47 Gbit/sec
>

What does the small packet or non-TCP performance look like for STT vs
VXLAN?  My concern is that STT looks like it is a one trick pony since
all your numbers show is TCP TSO performance, and based on some of the
comments in your patches it seems like other protocols such as UDP are
going to suffer pretty badly due to things like the linearization overhead.

- Alex
