From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 15/22] route: Extend flow representation with
 tunnel key
Date: Mon, 20 Jul 2015 14:27:29 +0200
Message-ID: <20150720122729.GB17423@pox.localdomain>
References: <cover.1437137396.git.tgraf@suug.ch>
 <d8d4304d6c32149bdf34466925b520f82a024ec2.1437137396.git.tgraf@suug.ch>
 <alpine.LFD.2.11.1507172320520.2410@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com,
	ast@plumgrid.com, weichunc@plumgrid.com, netdev@vger.kernel.org,
	dev@openvswitch.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38337 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704AbbGTM1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 08:27:32 -0400
Received: by wibxm9 with SMTP id xm9so24786323wib.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 05:27:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1507172320520.2410@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/15 at 11:25pm, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 17 Jul 2015, Thomas Graf wrote:
> 
> > Add a new flowi_tunnel structure which is a subset of ip_tunnel_key to
> > allow routes to match on tunnel metadata. For now, the tunnel id is
> > added to flowi_tunnel which allows for routes to be bound to specific
> > virtual tunnels.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > ---
> 
> > +struct flowi_tunnel {
> > +	__be64			tun_id;
> > +};
> > +
> >  struct flowi_common {
> >  	int	flowic_oif;
> >  	int	flowic_iif;
> > @@ -30,6 +34,7 @@ struct flowi_common {
> >  #define FLOWI_FLAG_ANYSRC		0x01
> >  #define FLOWI_FLAG_KNOWN_NH		0x02
> >  	__u32	flowic_secid;
> > +	struct flowi_tunnel flowic_tun_key;
> 
> 	New input key for fib rules? It should be initialized
> at some places, we should not provide random values:

Good catch. I see several other fields uninitialized as well
but they only seemed used in the output path.
