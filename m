From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/9] batman-adv: add UNICAST_4ADDR packet
	type
Date: Sat, 03 Nov 2012 15:22:26 -0400 (EDT)
Message-ID: <20121103.152226.244759041688205348.davem@davemloft.net>
References: <1351968514-12357-1-git-send-email-ordex@autistici.org>
 <1351968514-12357-2-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1351968514-12357-2-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Date: Sat,  3 Nov 2012 19:48:26 +0100

> The current unicast packet type does not contain the orig source address. This
> patches add a new unicast packet (called UNICAST_4ADDR) which provides two new
> fields: the originator source address and the subtype (the type of the data
> contained in the packet payload). The former is useful to identify the node
> which injected the packet into the network and the latter is useful to avoid
> creating new unicast packet types in the future: a macro defining a new subtype
> will be enough.
> 
> Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

Your packet layouts are very poorly designed and I want you to stop
and think seriously about things before extending things further.

All of this __packed stuff is a serious problem.

It means that on RISC system, fields such as your 32-bit sequence
number, will be read and written using byte loads and stores.

This is terrible.

Instead, design the structures so that they are full filled out to
at least 4 byte boundaries, so that they and the contents after
them, are 4 byte aligned too.

Then you won't need to mark all of your packet header structs
with __packed, and therefore the compiler can use full 32-bit
loads and stores to access 32-bit fields.

I'm not applying this series, sorry, it just continues a major
problem that the batman-adv code already has.
