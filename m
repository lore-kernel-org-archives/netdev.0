From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net/sched: add ACT_CSUM action to update packets
 checksums
Date: Tue, 17 Aug 2010 08:36:42 -0400
Message-ID: <1282048602.5765.752.camel@bigi>
References: <20100816211542.GA21083@n7mm.org> <1281996019.5765.6.camel@bigi>
	 <20100816230217.GA24125@n7mm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:40018 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab0HQMgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 08:36:47 -0400
Received: by qyk10 with SMTP id 10so598941qyk.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 05:36:46 -0700 (PDT)
In-Reply-To: <20100816230217.GA24125@n7mm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-17 at 01:02 +0200, Gr=C3=A9goire Baron wrote:

> You're rigth. I will correct that, maybe using a macro which is
> specialised to get the protocol structure ...
> However, this macro could call a 'goto' instruction. Is it really a g=
ood
> idea? Tell me. Are you sure a function is appropriate?

Do you even need the goto fail? It seems you could short-circuit and
return 0 (at least thats what the goto seems to do)

But i really dont want to complicate this;=20
In the minimal i think you can make code like this

=3D=3D=3D=3D
       struct icmphdr *icmph;
+       int hl;
+       int ntkoff;
+
+       ntkoff =3D skb_network_offset(skb);
+
+       hl =3D ihl + sizeof(*icmph);
+
+       if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+           (skb_cloned(skb) &&
+            !skb_clone_writable(skb, hl + ntkoff) &&
+            pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+               goto fail;
=3D=3D=3D

reusable - return 0 if fail else return 1 etc etc

BTW, another comment: icmp and igmp have unused parameter iph
passed to them - probably cut and paste.

cheers,
jamal

