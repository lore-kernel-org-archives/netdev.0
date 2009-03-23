From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: ucc_geth: nf_conntrack: table full, dropping packet.
Date: Mon, 23 Mar 2009 13:25:31 +0100
Message-ID: <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:38143 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167AbZCWMZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 08:25:33 -0400
In-Reply-To: <49C77D71.8090709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 13:15:45:
> 
> Joakim Tjernlund wrote:
> > doing a "ping -f -l 3" on my host towards my board on linus tree as of 

> > Friday results in lots of:
> > nf_conntrack: table full, dropping packet.
> > nf_conntrack: table full, dropping packet.
> > nf_conntrack: table full, dropping packet.
> > __ratelimit: 11 callbacks suppressed
> > nf_conntrack: table full, dropping packet.
> > nf_conntrack: table full, dropping packet.
> > nf_conntrack: table full, dropping packet.
> > nf_conntrack: table full, dropping packet.
> > 
> > for ucc_geth on a MPC832x.
> > This really looks strange to me, ideas?
> 
> What does /proc/net/netfilter/nf_conntrack show?

There is no /proc/net/netfilter/nf_conntrack. There is a
/proc/net/nf_conntrack though and it is empty. If I telnet
to the board I see:
ipv4     2 tcp      6 431990 ESTABLISHED src=192.168.1.15 dst=192.168.1.17 
sport=56445 dport=23 src=192.168.1.17 dst=192.168.1.15 sport=23 
dport=56445 [ASSURED] use=1
ipv4     2 udp      17 7 src=192.168.1.228 dst=192.168.1.255 sport=138 
dport=138 [UNREPLIED] src=192.168.1.255 dst=192.168.1.228 sport=138 
dport=138 use=1
ipv4     2 udp      17 20 src=127.0.0.1 dst=127.0.0.1 sport=34261 dport=53 
[UNREPLIED] src=127.0.0.1 dst=127.0.0.1 sport=53 dport=34261 use=1
ipv4     2 udp      17 2 src=192.168.1.199 dst=192.168.1.255 sport=138 
dport=138 [UNREPLIED] src=192.168.1.255 dst=192.168.1.199 sport=138 
dport=138 use=1
ipv4     2 udp      17 20 src=127.0.0.1 dst=127.0.0.1 sport=40417 dport=53 
[UNREPLIED] src=127.0.0.1 dst=127.0.0.1 sport=53 dport=40417 use=1

 Jocke

