From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: BUG: 2.6.25-rc1: iptables postrouting setup causes oops
Date: Wed, 13 Feb 2008 08:42:15 -0800
Message-ID: <47B31DE7.9060400@kernel.org>
References: <1202816761.3299.19.camel@moss.renham>	<20080213004829.fd8afdc7.akpm@linux-foundation.org>	<20080213101024.39347322@dhcp-252-066.norway.atmel.com> <20080213012231.46865608.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>,
	Ben Nizette <bn@niasdigital.com>,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932849AbYBMQnX@vger.kernel.org>
In-Reply-To: <20080213012231.46865608.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Haavard,

It means your application is not capable(sic) of using the upper 32-bits
of the 64-bit capability sets supported by this newer kernel.

You might consider rebuilding the offending application linking it
against a newer version of libcap:

http://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/

However, it is a warning and, for any existing app that doesn't care
about newly added capabilities, the warning is benign.

Cheers

Andrew

Andrew Morton wrote:
| On Wed, 13 Feb 2008 10:10:24 +0100 Haavard Skinnemoen
<hskinnemoen@atmel.com> wrote:
|
|> On Wed, 13 Feb 2008 00:48:29 -0800
|> Andrew Morton <akpm@linux-foundation.org> wrote:
|>
|>> On Tue, 12 Feb 2008 22:46:01 +1100 Ben Nizette <bn@niasdigital.com>
wrote:
|>>
|>>> On an AVR32, root over NFS, config attached, running (from a startup
|>>> script):
|>>>
|>>> iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
|>>>
|>>> Results in (dmesg extract including a bit of context for good measure):
|>>> -------------8<----------------
|>>> VFS: Mounted root (nfs filesystem).
|>>> Freeing init memory: 72K (90000000 - 90012000)
|>>> eth0: no IPv6 routers present
|>>> warning: `dnsmasq' uses 32-bit capabilities (legacy support in use)
|> Hmm. What does that mean? What size do capabilities normally have?
|
| My near-namesake put than in, but I immediately forgot what it means?
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFHsx3n+bHCR3gb8jsRAjlNAKDK4RLJsPsMPN96JJnTj3U25Bx91ACdESeN
2P3V2ISny33KY6v107iHsKU=
=1jND
-----END PGP SIGNATURE-----
