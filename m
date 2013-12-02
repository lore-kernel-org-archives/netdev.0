From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] Fix ARM BUILD_BUG_ON() errors with
	batman-adv
Date: Mon, 02 Dec 2013 13:38:38 -0500 (EST)
Message-ID: <20131202.133838.1257454198436895412.davem@davemloft.net>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk>
 <20131130.160547.837987320410619405.davem@davemloft.net>
 <201312021858.48074.sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org
To: sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <201312021858.48074.sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Date: Mon, 2 Dec 2013 18:58:47 +0100

> Therefore I'd suggest to pick Russels patch, I can send a fix for 
> batadv_interface_rx() later, too.

You are ignoring the downside of Russel's patch which is that it
negatively impacts many architectures, in that now the compiler
can make no assumptions as to the alignment of a structure marked
with "packed" and therefore, for example, a 32-bit load will
be done with 4 byte loads, shifts, and masking.

Please just 4 byte align your structures.  I can't believe that
you cannot make this work cleanly.

Why can't you just include that fourth final byte in the batadv_header
structure and have the sub-header types just interpret it differently
or ignore it?

This is getting frustrating, I seemed clear to me that the non-packed
suggestions given to you so far were both reasonable and easy to
implement.
