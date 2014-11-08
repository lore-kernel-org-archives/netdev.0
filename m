From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] udptunnel: Add SKB_GSO_UDP_TUNNEL during gro_complete.
Date: Fri, 7 Nov 2014 19:54:51 -0800
Message-ID: <CAEP_g=9Z4_xOnPJDcxGgSPvw1Heu5FGrij_L5Xbi6FeFfAwLvQ@mail.gmail.com>
References: <1415391969-108511-1-git-send-email-jesse@nicira.com> <28743.1415411491@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:41565 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752534AbaKHDzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 22:55:13 -0500
Received: by mail-qc0-f172.google.com with SMTP id i17so3573825qcy.31
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 19:55:12 -0800 (PST)
In-Reply-To: <28743.1415411491@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2014 at 5:51 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
> Jesse Gross <jesse@nicira.com> wrote:
>
>>When doing GRO processing for UDP tunnels, we never add
>>SKB_GSO_UDP_TUNNEL to gso_type - only the type of the inner protocol
>>is added (such as SKB_GSO_TCPV4). The result is that if the packet is
>>later resegmented we will do GSO but not treat it as a tunnel. This
>>results in UDP fragmentation and since that is not the original layout
>>of the skb, a panic in skb_segment().
>>
>>Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>>Signed-off-by: Jesse Gross <jesse@nicira.com>
>>---
>>This problem occurs back to 3.14 for VXLAN but the FOU portion needs to
>>be removed for kernels other than the 'net' tree.
>
>         This patch does not resolve the problem when applied to a
> 3.17-ish kernel; the panic message is below, and appears to be
> unchanged.

Hmm, OK, thanks for testing. I think this patch is probably still good
to apply as it may solve a problem after we get this one figured out.
