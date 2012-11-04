From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 1/9] batman-adv: add UNICAST_4ADDR packet
	type
Date: Sun, 04 Nov 2012 12:20:13 +0100
Message-ID: <5244128.ID77evUSAJ@sven-laptop.home.narfation.org>
References: <1351968514-12357-1-git-send-email-ordex@autistici.org>
 <20121103.152226.244759041688205348.davem@davemloft.net>
 <12758662.vFhVQet4vg@sven-laptop.home.narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2554706.VRIlKnAMNm";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <12758662.vFhVQet4vg-S/pmIDWWJIwhrEaHGRlFQnOel7F/LzPIcbWoRP8EXgk@public.gmane.org>
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


--nextPart2554706.VRIlKnAMNm
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

On Sunday 04 November 2012 11:29:29 Sven Eckelmann wrote:
> On Saturday 03 November 2012 15:22:26 David Miller wrote:
> [...]
> 
> > Your packet layouts are very poorly designed and I want you to stop
> > and think seriously about things before extending things further.
> 
> You are right about the packet design/layout. But I also have some problems
> with the following statement. Maybe you can help me to resolve it.
> 
> > All of this __packed stuff is a serious problem.
> > 
> > It means that on RISC system, fields such as your 32-bit sequence
> > number, will be read and written using byte loads and stores.
> > 
> > This is terrible.
> > 
> > Instead, design the structures so that they are full filled out to
> > at least 4 byte boundaries, so that they and the contents after
> > them, are 4 byte aligned too.
> > 
> > Then you won't need to mark all of your packet header structs
> > with __packed, and therefore the compiler can use full 32-bit
> > loads and stores to access 32-bit fields.
> 
> Ok, lets assume batman-adv has everything 4 byte aligned and we are running
> on a machine without unaligned r/w access. The machine may issues bus
> errors and so on.
> 
> Now also assume following really unusual situation: We get our data from a
> ethernet driver and the skb stores the ethernet header. The start of the
> ethernet header is perfectly aligned (4 or even 16 byte boundary aligned).
> The the header is 14/18 byte long (6 byte src, 6 byte dst, 2 byte ethertype
> and maybe 4 byte vlan). Now the payload starts only on a 2 byte boundary ->
> it is never 4 byte boundary aligned. A 32 bit read now causes different
> variations of problems (reminder: bus error).
> 
> This brings me to the question: Why should the "32 bit align everything
> relative to the start of the struct" approach help to resolve the situation
> for the access of 32 bit data structure members? May I am missing some
> information?

To push this question in a direction: May I assume that the driver always 
ensures that the ethernet header is 4 byte boundary - NET_IP_ALIGN (2) 
aligned?

When yes, this would result in a slight variations of your suggestion: 
unicast/bcast headers have to end at 4 bytes boundary + 2 bytes. The reason is 
easy to explain. batman-adv unicast/bcast headers are used to encapsulate the 
important parts of an ethernet frame:

Ethernet Header for P2P | batman-adv header stuff | ethernet header | payload.

Would you aggree?

Thanks,
	Sven
--nextPart2554706.VRIlKnAMNm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQlk9tAAoJEF2HCgfBJntG/bUP/3hWttmH1Rz/+9P6O2ObkNod
FRg5Lr1HyE/h5ir2W7HgQ0FPACH5zToS0Fsi8GoN2/U4/Xte9Jmjbe3Y6AhCBDut
Ppt1TzWcZq8ja0Q/Q18I7qdXhmR37f+4nhReIOTImKR3OT6h3kjIBfAzG6Dz++9F
cjAA1ffBRxc3vP9cAxZbGQmsyPJ2W9k/BaywSNzd4pRFDqHSjNfhWBvf/z22DMJj
nt9bcbMlQwAXv8KCcoM0euuIbEDIBkxmynAwiIgmlpcctBu7emDTwYxPMdE6vw6o
UvCd7XRqlYLzke9WKrMvfmHguRpPxhgpxYa827G8s7pC9sVU14cgDY98WOoJGFp2
fw83wkmdkqngPt2dza2+zBQeDu2loTLnUVYOvir+ZVXfVHTAJk2WZkjD2TAOp0tI
/YTkzkddK5oOtp0exRBg33nNUoVy8sxsWHEDh/bMhH7Uv7GwR3C2LIkUePjgpnIE
3t8p9Dv1kOQEZIkD5IFOHhZOSiI5O7v4UUxFTDbiUVGa5mC4zLmICIJ13GZ+HYUd
HnYZeWOhmX71XUzyIWmfC37tkQTOXMPrJxCRS3IVi/YNeaWhEuqyvFHL/EHHANfb
eSt40ur8U+sqTR5O8C5kuxNNZ5yIfVMRh/B37G4f3XK+ObI1bym8TqIkN8+4h5wx
TsOFeo6AaeO9K0pCyVwT
=SwoZ
-----END PGP SIGNATURE-----

--nextPart2554706.VRIlKnAMNm--
