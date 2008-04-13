From: Patrick McHardy <kaber@trash.net>
Subject: Re: raw socket and iptables rules
Date: Sun, 13 Apr 2008 08:32:14 +0200
Message-ID: <4801A8EE.3040808@trash.net>
References: <690153640804100451y7a7f29fawfd6b3f1ba8f62a51@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Gabor Fekete <kotrelmaller.borgenbach@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <690153640804100451y7a7f29fawfd6b3f1ba8f62a51@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gabor Fekete wrote:
> Hi,
> 
> I'm writing a C code that sends IP datagrams using a RAW socket.
> The only problem I have is that it seems that the MASQUERADE rule
> I have does not apply for the packets sent via this socket.
> 
> Is it so, that raw sockets bypass iptables?
> What can I do to make iptables to process these packets?


MASQUERADE leaves packets with saddr=0.0.0.0 pass without SNAT.
So that might be the reason. Another possibility is that these
packets match an existing connection, the NAT table only sees
the first packet of each connection. Third option would be
invalid IP headers, but you'd see a message in that case.
