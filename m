From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sun, 29 Nov 2009 21:35:08 +0100
Message-ID: <20091129203508.GB18259@sch.bme.hu>
References: <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com> <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi> <20091128151515.GA20476@sch.bme.hu> <4B1145F1.3090704@trash.net> <1259424278.3864.16.camel@bigi> <4B1158CE.90803@trash.net> <1259429774.3864.41.camel@bigi> <20091128190500.GB12264@sch.bme.hu> <1259437442.3864.61.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from centaur.sch.bme.hu ([152.66.208.5]:50316 "EHLO
	centaur.sch.bme.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbZK2UfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 15:35:04 -0500
Content-Disposition: inline
In-Reply-To: <1259437442.3864.61.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On szo, nov 28, 2009 at 02:44:02 -0500, jamal wrote:
> > The source address *is* unicast. 
> 
> Sorry - I meant the route type is unicast. The fact that an address is
> unicast or not is already dealt with by the time you get to source
> address validation (in ip_input())
> 
> > The problem is that the routing setup is
> > asymmetrical, as Patrick has already mentioned: we're using a mark to
> > force certain packets (those that have matching sockets on the host) being
> > delivered locally.
> >
> > In the other direction, reply packets won't be marked by the iptables
> > rules and thus will be routed on egress just fine. 
> 
> In that case i dont understand the reluctance to use unicast routes.
> Maybe you can explain and put me at ease because i see youve put extra
> effort to use local addresses. 

The short answer is: it doesn't work with unicast routes.

The story is that we really do want to deliver these packets locally, as
if the destination IP address was locally configured on the host. The only
way I know of to get the packet to ip_local_deliver() is by using a local
route.

(Now that you mentioned this I've actually gave it a try. Changing 'local'
in the route to 'unicast' doesn't work at all: incoming packets get
dropped because forwarding is not enabled on the ingress interface.)

-- 
KOVACS Krisztian
