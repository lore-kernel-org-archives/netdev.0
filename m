From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 14:10:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122141026.6a728abe.davem@redhat.com>
References: <OFBED1B971.06995FF1-ON88256E23.006E3E55@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OFBED1B971.06995FF1-ON88256E23.006E3E55@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The most portable and simple algorithm to solve this on the reader
side is (and I recommend we don't special case this on 64-bit platforms
just to get wider testing):

	u32 high, low1, low2;

	do {
		low1 = stat & 0xffffffff;
		rmb();
		high = stat >> 32;
		rmb();
		low2 = stat & 0xffffffff;
	} while (low2 < low1);

Something like that.  The idea is to sample the lower 32-bit twice
and if it overflows resample both high and low halfs.
