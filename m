From: Andi Kleen <ak@suse.de>
Subject: Re: Debug kernel network hook chain or why has Check Point Firewall module problems with IPv6
Date: Mon, 22 Apr 2002 09:22:52 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020422092252.A17861@wotan.suse.de>
References: <22830000.1019458033@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Peter Bieringer <pb@bieringer.de>
Content-Disposition: inline
In-Reply-To: <22830000.1019458033@localhost>
List-Id: netdev.vger.kernel.org

On Mon, Apr 22, 2002 at 08:47:13AM +0200, Peter Bieringer wrote:
> Looks like CP never sees (or recognizes) packets leaving the
> firewalled host from a dual-stack application.

Linux has no "generic" firewall hooks, only protocol specific ones.  
Checkpoint is probably using the v4 specific ones only.
Other protocols can be received (by registering a protocol to ETH_P_ALL via
SOCK_PACKET or in the kernel), but not stolen from protocol handlers. 

2.2 had no working firewall chains for IPv6, 2.4 has a v6 netfilter
interface.

BTW the CheckPoint module seems to leak routes too at least on 2.2, 
there are regular reports of that.

> BTW: incoming SSH traffic via IPv6 is completly unrecognized and
> therefore quietly accepted. Looks like CP never sees or recognize
> incoming IPv6 packets at all - same issue, if on a IPv4-netfiltererd
> box the IPv6-netfilter was forgotten...

Sounds like a serious CheckPoint bug.


-Andi
