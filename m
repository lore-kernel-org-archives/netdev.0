From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: a question about XFRM_POLICY_FWD
Date: Tue, 14 Dec 2004 08:50:03 +0900
Message-ID: <41BE2AAB.1070904@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, herbert@gondor.apana.org.au
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I would like to ask about meaning of XFRM_POLICY_FWD,
although a question may have been asked before.

I configured IPsec tunnel and thought XFRM_POLICY_FWD
might be confusing.

A forwarding policy which is represent with XFRM_POLICY_FWD
in the kernel affects only in-comming forwarding packet.
The policy does not affect out-going forwarding packet and
input packet to a security gateway itself.

If we want to connect network 2001:DB8:1::/64 and 2001:DB8:3::/64
with SGW(A) and SGW(B),

---------------SGW(A)==================SGW(B)---------
2001:DB8:1::/64        2001:DB8:2::/64        2001:DB8:3::/64

=== represents IPsec tunnel
--- represents a network behind SGW.

The addresses of each SGW are:

SGW(A) internal address 2001:DB8:1::A/64
SGW(A) external address 2001:DB8:2::A/64
SGW(B) external address 2001:DB8:2::B/64
SGW(B) internal address 2001:DB8:3::B/64

We need to configure policies in SGW(A) which are represent with setkey command are
spdadd 2001:DB8:1::/64 2001:DB8:3::/64 any -P out ipsec esp/tunnel/2001:DB8:2::A-2001:DB82::B/require;
spdadd 2001:DB8:3::/64 2001:DB8:1::/64 any -P fwd ipsec esp/tunnel/2001:DB8:2::B-2001:DB82::A/require;

However, the above policies does not allow SGW(A) to receive packest from 2001:DB8:3::/64 to
2001:DB8:1::A/64 because there is no policy for "INPUT".

To let the packet reach 2001:DB8:1::A, we needs an additional policy
spdadd 2001:DB8:3::/64 2001:DB8:1::A/128 any -P in ipsec esp/tunnel/2001:DB8:2::B-2001:DB82::A/require;

Totally, we need three policies for the configuration in a SGW.

I think , from the point of view of user or administrator, why forward does not allow the packet instead
2001:DB8:1::A is included in network 2001:DB8:1::/64. And I also think why I can not configure out-going
forward policy with "fwd". Anyway XFRM_POLICY_FWD or "fwd" might be confusing.

What does XFRM_POLICY_FWD or direction="forward" means in the architecture design?

Of course I know the implementation :-p

P.S.
IMHO,
We should remove or obsolete XFRM_POLICY_FORWARD and use XFRM_POLICY_IN instead of it.
or
We should lookup out-going forwarding packet with XFRM_POLICY_FORWARD.

--
Kazunori Miyazawa
