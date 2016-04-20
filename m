From: Ingo Saitz <ingo@stud.uni-hannover.de>
Subject: Re: skb_at_tc_ingress helper breaks compilation of oot modules
Date: Wed, 20 Apr 2016 12:53:54 +0200
Message-ID: <20160420105354.GA12348@pinguin.zoo>
References: <20160420102148.GA18615@echse.zoo>
 <57175C13.8080109@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Saitz <ingo@stud.uni-hannover.de>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1n.rrzn.uni-hannover.de ([130.75.2.107]:60185 "EHLO
	mailout1n.rrzn.uni-hannover.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751002AbcDTKx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 06:53:58 -0400
Content-Disposition: inline
In-Reply-To: <57175C13.8080109@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 12:38:11PM +0200, Daniel Borkmann wrote:
> Hmm, your fail.c test case only contains '#include <net/ipv6.h>'?

No, only when building oot modules (virtualbox, and I found batman-adv
having the same issue), so I reduced it to the most simple test case. T=
his
actually builds a fail.ko on 4.4.7 with CONFIG_NET_CLS_ACT=3Dy without
errors.

> Note, upstream kernel never cared about out-of-tree modules, only
> in-tree code. ;) Did you run into an issue with any in-tree code?

A current fix for oot modules would be to add:

#include <uapi/linux/pkt_cls.h>

in front of that include for kernel >=3D 4.5=E2=80=A6

    Ingo
--=20
Kennedy's Lemma:
    If you can parse Perl, you can solve the Halting Problem.

http://www.perlmonks.org/?node_id=3D663393
