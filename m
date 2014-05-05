From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 3/3] net: mvneta: Introduce a software TSO implementation
Date: Mon, 5 May 2014 11:47:02 -0300
Message-ID: <20140505144702.GB12693@arch.cereza>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1397170682-19138-4-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, cmetcalf@tilera.com,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Willy Tarreau <w@1wt.eu>, Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Simon Guinot <sguinot@lacie.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:38439 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932448AbaEEOre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 10:47:34 -0400
Content-Disposition: inline
In-Reply-To: <1397170682-19138-4-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On 10 Apr 07:58 PM, Ezequiel Garcia wrote:
[..]
> +
> +	/* Calculate expected number of TX descriptors */
> +	desc_count =3D skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_=
frags;
> +	if ((txq->count + desc_count) >=3D txq->size)
> +		return 0;
> +

Is this calculus correct? Does it give the accurate number of needed
descriptors or is it an approximation?

Tilera's tilegx driver does a much stricter descriptor count (see
tso_count_edescs). This functions loops through the skb_frag_t fragment=
s
as it's done later in the data egress, hence strictly counting the
needed descriptors.

However, as it's a much heavier routine than the one shown above,
I'm wondering if we can get away without it.

Willy, Any ideas here?
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
