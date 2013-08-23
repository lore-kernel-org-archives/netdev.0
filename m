From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: tcp_probe: allow more advanced ingress
 filtering by mark
Date: Fri, 23 Aug 2013 08:13:33 -0700
Message-ID: <1377270813.8828.6.camel@edumazet-glaptop>
References: <1377267393-24604-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:60116 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755599Ab3HWPNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 11:13:40 -0400
Received: by mail-la0-f49.google.com with SMTP id ev20so577371lab.36
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 08:13:39 -0700 (PDT)
In-Reply-To: <1377267393-24604-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-23 at 16:16 +0200, Daniel Borkmann wrote:
> Currently, the tcp_probe snooper can either filter packets by a given
> port (handed to the module via module parameter e.g. port=80) or lets
> all TCP traffic pass (port=0, default). When a port is specified, the
> port number is tested against the sk's source/destination port. Thus,
> if one of them matches, the information will be further processed for
> the log.
> 
> As this is quite limited, allow for more advanced filtering possibilities
> which can facilitate debugging/analysis with the help of the tcp_probe
> snooper. Therefore, similarly as added to BPF machine in commit 7e75f93e
> ("pkt_sched: ingress socket filter by mark"), add the possibility to
> use skb->mark as a filter.
> 
> If the mark is not being used otherwise, this allows ingress filtering
> by flow (e.g. in order to track updates from only a single flow, or a
> subset of all flows for a given port) and other things such as dynamic
> logging and reconfiguration without removing/re-inserting the tcp_probe
> module, etc. Simple example:
> 
>   insmod net/ipv4/tcp_probe.ko fwmark=8888 full=1
>   ...
>   iptables -A INPUT -i eth4 -t mangle -p tcp --dport 22 \
>            --sport 60952 -j MARK --set-mark 8888
>   [... sampling interval ...]
>   iptables -D INPUT -i eth4 -t mangle -p tcp --dport 22 \
>            --sport 60952 -j MARK --set-mark 8888
> 
> The current option to filter by a given port is still being preserved. A
> similar approach could be done for the sctp_probe module as a follow-up.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---

Well, why not adding ability to load/use a BPF filter instead ? ;)
