From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPVS] Fix compiler warning about unused
 register_ip_vs_protocol
Date: Tue, 20 Nov 2007 17:44:24 -0800 (PST)
Message-ID: <20071120.174424.119977201.davem@davemloft.net>
References: <4742CE4A.2000102@openvz.org>
	<20071121013801.GB11665@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35637
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753307AbXKUBo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:44:26 -0500
In-Reply-To: <20071121013801.GB11665@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Wed, 21 Nov 2007 10:38:02 +0900

> On Tue, Nov 20, 2007 at 03:08:42PM +0300, Pavel Emelyanov wrote:
> > This is silly, but I have turned the CONFIG_IP_VS to m,
> > to check the compilation of one (recently sent) fix
> > and set all the CONFIG_IP_VS_PROTO_XXX options to n to
> > speed up the compilation.
> > 
> > In this configuration the compiler warns me about
> > 
> >   CC [M]  net/ipv4/ipvs/ip_vs_proto.o
> > net/ipv4/ipvs/ip_vs_proto.c:49: warning: ‘register_ip_vs_protocol’ defined but not used
> > 
> > Indeed. With no protocols selected there are no
> > calls to this function - all are compiled out with
> > ifdefs.
> > 
> > Maybe the best fix would be to surround this call with
> > ifdef-s or tune the Kconfig dependences, but I think that
> > marking this register function as __used is enough. No?
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> That is kind of interesting.
> 
> On the one hand it might be more correct in some way to use some Kconfig
> foo to get rid of register_ip_vs_protocol, and also most of
> the body of ‘register_ip_vs_protocol() if no protocols are defined.
> 
> But on the other hand, its really a corner case, because in practice if
> you are going to use IPVS then you are going to need at least one
> protocol. So I'm happy with the simplicity of the __used solution, even
> though strictly speaking it is a lie.
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Ok, I've applied Pavel's patch.
