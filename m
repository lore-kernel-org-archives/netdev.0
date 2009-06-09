From: Patrick McHardy <kaber@trash.net>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Tue, 09 Jun 2009 13:40:34 +0200
Message-ID: <4A2E4A32.1060705@trash.net>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com>	 <20090608.143454.161329513.davem@davemloft.net>	 <4A2E4077.8080407@trash.net> <91ac27070906090427k6f57745xc72f9fcb6801957a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gil Beniamini <gil.beniamini@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758359AbZFILkr@vger.kernel.org>
In-Reply-To: <91ac27070906090427k6f57745xc72f9fcb6801957a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gil Beniamini wrote:
> 9Jun09, The problem was seen with eth1 using driver e1000e, but also
> was reproduced on 3c59x, to me it seems that the problem is not
> related to a specific nic driver.
> VLAN is running for other NICs, but on the application specific nic
> (eth1) I use PF_PACKET (SOCK_RAW) , in order to get  the raw-packet
> from the underlying device, and this start working again (like in
> older kernel) as soon as the application set the socket to PROMISC
> mode.

OK, that might explain it. e1000e performs VLAN filtering in hardware
and unless there are VLANs configured locally, all VLANs are filtered
out. Are you seeing seeing only unicast VLAN traffic or no VLAN traffic
at all? Please post a dump of the packets with and without promiscous
mode.
