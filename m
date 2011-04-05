From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: extending feature word.
Date: Tue, 05 Apr 2011 13:07:41 +0100
Message-ID: <1302005261.2932.4.camel@bwh-desktop>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
	 <20110402124207.GB3147@rere.qmqm.pl>
	 <BANLkTi=hCqT5BPe926N36omObpYvMcNtjg@mail.gmail.com>
	 <20110405113007.GA21358@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35559 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab1DEMHo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 08:07:44 -0400
In-Reply-To: <20110405113007.GA21358@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-05 at 13:30 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Sat, Apr 02, 2011 at 08:09:14PM -0700, Mahesh Bandewar wrote:
> > On Sat, Apr 2, 2011 at 5:42 AM, Micha=C5=82 Miros=C5=82aw <mirq-lin=
ux@rere.qmqm.pl> wrote:
> > > On Fri, Apr 01, 2011 at 07:07:05PM -0700, Mahesh Bandewar wrote:
> > > If you want to split the work, it would be clearer to first conve=
rt
> > > hw_features and wanted_features (with all the core code touching =
it -
> > > this is the easy part), then vlan_features (this includes drivers=
'
> > > and VLAN code) and then features (it's all over).
> > I like the idea of splitting but it will be only useful when all of=
 it
> > is done and not partially, isn't it? Or am I missing something?
>=20
> Since this is a big change, when split it might be easier to follow.
> OTOH, with your idea of macro it might be easier to do incremental
> changes (I think this will be a lot of work for no gain in this case)=
=2E

I strongly disagree with using macros for this.  They are very likely t=
o
conflict with other identifiers..

We might be able to get away with something like:

	union {
		u32 features;
		u32 feature[N];
	};
	union {
		u32 vlan_features;
		u32 vlan_feature[N];
	};
	union {
		u32 hw_features;
		u32 hw_feature[N];
	};

(assuming hw_features is new enough that there is no need for the
alias).

Anyway, if we're going to put all the feature words in net_device
there's no longer any reason for NETIF_F_LOOPBACK not to be in the firs=
t
word.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

