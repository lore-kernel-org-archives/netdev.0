From: Per Hedeland <per@hedeland.org>
Subject: RE: [Bonding-devel] [PATCH] [bonding 2.6] Add balance-xor-ip bonding mode
Date: Thu, 8 Jan 2004 17:58:33 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081658.i08GwXZV059631@pluto.hedeland.org>
References: <72A87F7160C0994D8C5A36E2FDC227F502B3E9BE@txnexc01.americas.cpqcorp.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        tony.cureington@hp.com
In-Reply-To: <72A87F7160C0994D8C5A36E2FDC227F502B3E9BE@txnexc01.americas.cpqcorp.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Cureington, Tony" <tony.cureington@hp.com> wrote:
>
>I'm curious of the reasoning behind "u ^= (u >> 24) ^ (u >> 16) ^ (u >> 8);", what advantages does it have over using the xor'd addresses just before this line? Maybe someone loaded decaf on me this morning? :-/

The idea is to take all octets of the addresses into account (similar
logic is already used in bond_alb.c btw). E.g. if the number of slaves
is a power of 2 (2 or 4 is probably very common), a full_address %
num_slaves operation will effectively only use one octet (happens to be
the first one on x86, which is probably the worst choice, but of course
that could be compensated for). Or am I missing something?

--Per Hedeland
per@hedeland.org
