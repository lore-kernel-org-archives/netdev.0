From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v2 net] ipv4: fix tunneled VM traffic over hw VXLAN/GRE
 GSO NIC
Date: Fri, 3 Jan 2014 08:44:36 +0200
Message-ID: <CAJZOPZJrSMsPoQXZ5if3Ak3vhVpPCz_=oO9eCcqk_KeopkWwKQ@mail.gmail.com>
References: <1388092222-4549-1-git-send-email-weichunc@plumgrid.com>
	<20140102.190743.459474382050321416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Wei-Chun Chao <weichunc@plumgrid.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:47014 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaACGoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 01:44:37 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so14984485pdj.4
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 22:44:36 -0800 (PST)
In-Reply-To: <20140102.190743.459474382050321416.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 3, 2014 at 2:07 AM, David Miller <davem@davemloft.net> wrote:
> From: Wei-Chun Chao <weichunc@plumgrid.com>
> Date: Thu, 26 Dec 2013 13:10:22 -0800
>
>> VM to VM GSO traffic is broken if it goes through VXLAN or GRE
>> tunnel and the physical NIC on the host supports hardware VXLAN/GRE
>> GSO offload (e.g. bnx2x and next-gen mlx4).
>>
>> Two issues -
>> (VXLAN) VM traffic has SKB_GSO_DODGY and SKB_GSO_UDP_TUNNEL with
>> SKB_GSO_TCP/UDP set depending on the inner protocol. GSO header
>> integrity check fails in udp4_ufo_fragment if inner protocol is
>> TCP. Also gso_segs is calculated incorrectly using skb->len that
>> includes tunnel header. Fix: robust check should only be applied
>> to the inner packet.
>>
>> (VXLAN & GRE) Once GSO header integrity check passes, NULL segs
>> is returned and the original skb is sent to hardware. However the
>> tunnel header is already pulled. Fix: tunnel header needs to be
>> restored so that hardware can perform GSO properly on the original
>> packet.
>>
>> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>

> Applied, thanks.

Hi Dave, as I wrote you earlier, could you also add it to your -stable queue?
