From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/5] soreuseport: UDP/IPv4 implementation
Date: Tue, 15 Jan 2013 19:14:55 +0000
Message-ID: <1358277295.2865.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <alpine.DEB.2.00.1301141140320.3523@pokey.mtv.corp.google.com>
	 <20130115075803.17ed2bc5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <netdev@markandruth.co.uk>,
	<eric.dumazet@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57289 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab3AOTO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 14:14:59 -0500
In-Reply-To: <20130115075803.17ed2bc5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-15 at 07:58 -0800, Stephen Hemminger wrote:
> On Mon, 14 Jan 2013 12:00:23 -0800 (PST)
> Tom Herbert <therbert@google.com> wrote:
> 
> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > index 79c8dbe..1dd1e93 100644
> > --- a/net/ipv4/udp.c
> > +++ b/net/ipv4/udp.c
> > @@ -139,6 +139,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
> >  {
> >  	struct sock *sk2;
> >  	struct hlist_nulls_node *node;
> > +	int uid = sock_i_uid(sk);
> >  
> 
> I am not a namespace expert, but it looks like this might have
> to use from_kuid_munged(). At a minimum it should be:
>          kuid_t uid = sock_i_uid(sk);

Right, and the comparison has to be done with uid_eq().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
