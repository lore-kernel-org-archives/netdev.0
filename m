From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: some tc commands fail on 2.6.29-rc6-git5, works on 2.6.28.7
Date: Wed, 4 Mar 2009 19:59:57 +0200
Message-ID: <200903041959.57439.denys@visp.net.lb>
References: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com> <1236135028.7883.44.camel@Maple> <a5d9929e0903040609x43dbeda9h26a882897a177400@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Dykstra <john.dykstra1@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:53705 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756524AbZCDSAT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 13:00:19 -0500
In-Reply-To: <a5d9929e0903040609x43dbeda9h26a882897a177400@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe good idea to use strace? (i dont know which flags useful, but usu=
ally i=20
use "-s 65536")
Just maybe it will give a bit more ideas what is happening.
But sure netdev developers can tell, if it is useful or not.

On Wednesday 04 March 2009 16:09:57 Joao Correia wrote:
> Hello
>
> Just to confirm that i also have all traffic control/shaping (QoS,
> connection limits, scheduling, etc) enabled on the config i use.
>
> Its not just the specific version of tc i posted, i tried one from
> last year (october, but i didnt note the exact build) with the same
> result.
>
> Cheers,
> Joao Correia
> Centro de Informatica
> Universidade da Beira Interior
> Portugal
>
> On Wed, Mar 4, 2009 at 2:50 AM, John Dykstra <john.dykstra1@gmail.com=
>=20
wrote:
> > On Tue, 2009-03-03 at 23:10 +0000, Joao Correia wrote:
> >> I have confirmed again that the exact same commands (as on the
> >> original message), work flawlessly on 2.6.28.7 without a hitch, an=
d,
> >> AFAIK, work as intended. I have also tried the latest 2.6.29-rc6-g=
it7
> >> and it still fails like on git6.
> >
> > I have also reproduced this on Linus' latest 2.6.29-rc6 tree, using=
 tc
> > version iproute2-ss071016 and a kernel config with all traffic cont=
rol
> > features enabled.
> >
> > The error reported by tc comes from the kernel-level check added by=
:
> >
> > =A0 =A0 =A0 =A0commit c1b56878fb68e9c14070939ea4537ad4db79ffae
> > =A0 =A0 =A0 =A0Author: Stephen Hemminger <shemminger@vyatta.com>
> > =A0 =A0 =A0 =A0Date: =A0 Tue Nov 25 21:14:06 2008 -0800
> >
> > =A0 =A0 =A0 =A0tc: policing requires a rate estimator
> >
> > =A0 =A0Found that while trying average rate policing, it was possib=
le to
> > =A0 =A0request average rate policing without a rate estimator. This=
 results
> > =A0 =A0in no policing which is harmless but incorrect.
> >
> > =A0 =A0Since policing could be setup in two steps, need to check
> > =A0 =A0in the kernel.
> >
> > =A0 =A0Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > I got the same error when using the tc version iproute2-ss090115 bu=
ilt
> > this evening from the public git repository.
> >
> > =A0-- John
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


