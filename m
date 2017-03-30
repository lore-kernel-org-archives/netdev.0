From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net-next v2] vxlan: fix ND proxy when skb doesn't have transport header offset
Date: Thu, 30 Mar 2017 08:41:51 +0200
Message-ID: <m360irs1u8.fsf@luffy.cx>
References: <20170329204704.26087-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:48482 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932731AbdC3Gua (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 02:50:30 -0400
In-Reply-To: <20170329204704.26087-1-vincent@bernat.im> (Vincent Bernat's
        message of "Wed, 29 Mar 2017 22:47:04 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 29 mars 2017 22:47 +0200, Vincent Bernat <vincent@bernat.im>=C2=
=A0:

> Parsing of neighbor discovery options is done earlier to ignore the
> whole packet in case of a malformed option. Moreover, the assumption the
> skb was linear is removed and options are extracted with
> skb_header_pointer() as well. The check on the source link-layer address
> option is also more strict (for Ethernet, we expect the length field to
> be 1).

There is some parsing implemented in net/ipv6/ndisc.c, notably
ndisc_parse_options(). I don't know if this is a good idea to reuse
that: it may have the expectation that some IP processing has already
been done (for example, the IPv6 length has already been checked, the
SKB is expected to be linear).
--=20
Watch out for off-by-one errors.
            - The Elements of Programming Style (Kernighan & Plauger)
