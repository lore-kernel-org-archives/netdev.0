From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Mon, 11 Sep 2006 16:57:24 +0200
Message-ID: <20060911145724.GB27223@MAIL.13thfloor.at>
References: <20060815182029.A1685@castle.nmd.msu.ru> <200609081710.09124.dim@openvz.org> <20060908181154.GA8745@MAIL.13thfloor.at> <200609091157.24734.dim@openvz.org> <4505757B.3020004@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Mishin <dim@openvz.org>, Kir Kolyshkin <kir@openvz.org>,
	Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([213.145.232.33]:6874 "EHLO
	MAIL.13thfloor.at") by vger.kernel.org with ESMTP id S1751289AbWIKO5Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 10:57:25 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Content-Disposition: inline
In-Reply-To: <4505757B.3020004@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 11, 2006 at 04:40:59PM +0200, Daniel Lezcano wrote:
> Dmitry Mishin wrote:
> >On Friday 08 September 2006 22:11, Herbert Poetzl wrote:
> >
> >>actually the light-weight ip isolation runs perfectly
> >>fine _without_ CAP_NET_ADMIN, as you do not want the
> >>guest to be able to mess with the 'configured' ips at
> >>all (not to speak of interfaces here)
> >
> >It was only an example. I'm thinking about how to implement flexible 
> >solution, which permits light-weight ip isolation as well as full-fledged 
> >netwrok virtualization. Another solution is to split CONFIG_NET_NAMESPACE. 
> >Is it good for you?
> 
> Hi Dmitry,
> 
> I am currently working on this and I am finishing a prototype bringing
> isolation at the ip layer. The prototype code is very closed to
> Andrey's patches at TCP/UDP level. So the next step is to merge the
> prototype code with the existing network namespace layer 2 isolation.

you might want to take a look at the current Linux-VServer
implementation for the network isolation too, should be
quite similar to Andrey's approach, but maybe you can
gather some additional information from there

> IHMO, the solution of spliting CONFIG_NET_NS into CONFIG_L2_NET_NS
> and CONFIG_L3_NET_NS is for me not acceptable because you will need
> to recompile the kernel. The proper way is certainly to have a
> specific flag for the unshare, something like CLONE_NEW_L2_NET and
> CLONE_NEW_L3_NET for example.

I completely agree here, we need a separate namespace
for that, so that we can combine isolation and virtualization
as needed, unless the bind restrictions can be completely
expressed with an additional mangle or filter table (as
was suggested)

best,
Herbert

>   -- Daniel
