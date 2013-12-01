From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: Re: [PATCH] Fix ARM BUILD_BUG_ON() errors
	with	batman-adv
Date: Sun, 01 Dec 2013 01:27:34 +0100
Message-ID: <529A8276.9060002@meshcoding.com>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk>
 <529A46C4.9090906@meshcoding.com>
 <20131130230518.GC16735@n2100.arm.linux.org.uk>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20131130230518.GC16735-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
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

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/12/13 00:05, Russell King - ARM Linux wrote:
> On Sat, Nov 30, 2013 at 09:12:52PM +0100, Antonio Quartulli wrote:
>> I don't know the ARM architecture at all (I don't know if the
>> other batman-adv developers do), so could you please provide here
>> some more details about why that static check is failing? We
>> would like to address this issue differently rather than
>> re-adding the __packed attribute.
> 
> The reason is this struct becomes a size of 4 bytes, even though it
> only contains three uint8_t members.  This offsets the members of
> all structs that this struct is embedded in.
> 
> If you don't wish to fix this, then please make your subsystem 
> depend on !ARM because it's otherwise impossible to fix and can
> never work on ARM.
> 

I'd like to fix this.

Actually I can't really understand your explanation: struct
batadv_header is always used inside another parent structure and the
latter always has a uint8_t following the batadv_header, thus filling
that gap and aligning it to 4bytes.
I think this is also why we don't get this compiler error on any other
architecture. Or am I missing something?

I'll install a toolchain for ARM and I'll try to inspect it better. If
we have to make a change we should do it before 3.13 is release since
this change could possibly alter the packet layout.

- -- 
Antonio Quartulli
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlKagnYACgkQpGgxIkP9cwe1KgCeMUkV6xpNOsM4Bilc1e1uHpCG
8BAAnjsHJ/AHn8COhwiZ5wrKiIpQ0CFa
=D4xa
-----END PGP SIGNATURE-----
