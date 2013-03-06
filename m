From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH BUGFIX 2/6] pkt_sched: fix the update of eligible-group sets
Date: Wed, 6 Mar 2013 10:05:58 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7178@saturn3.aculab.com>
References: <20130226.173700.882998504986475149.davem@davemloft.net> <1362506702-4985-1-git-send-email-paolo.valente@unimore.it> <1362506702-4985-3-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<fchecconi@gmail.com>, <rizzo@iet.unipi.it>
To: "Paolo valente" <paolo.valente@unimore.it>,
	"Jamal Hadi Salim" <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1362506702-4985-3-git-send-email-paolo.valente@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Between two invocations of make_eligible, the system virtual time may
> happen to grow enough that, in its binary representation, a bit with
> higher order than 31 flips. This happens especially with
> TSO/GSO. Before this fix, the mask used in make_eligible was computed
> as (1UL<<index_of_last_flipped_bit)-1, whose value is well defined on
> a 64-bit architecture, because index_of_flipped_bit <= 63, but is in
> general undefined on a 32-bit architecture if index_of_flipped_bit > 31.
> The fix just replaces 1UL with 1ULL.
...
> -		unsigned long mask = (1UL << fls(vslot ^ old_vslot)) - 1;
> +		unsigned long mask = (1ULL << fls(vslot ^ old_vslot)) - 1;

I'm not sure you really want to be doing 64bit shifts on 32 bit
systems just to generate ~0ul.
probably worth a conditional.

	David
