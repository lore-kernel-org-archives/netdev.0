From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] Initialize dev_id sysfs attribute to -1 by default
Date: Fri, 7 Jun 2013 16:23:54 +0100
Message-ID: <1370618634.1903.3.camel@bwh-desktop.uk.level5networks.com>
References: <20130530132419.GA1368@fedora-17-guest.blr.amer.dell.com>
	 <87fvx4mvtl.fsf@nemi.mork.no>
	 <20130531121737.GB1311@fedora-17-guest.blr.amer.dell.com>
	 <51B1F1FF.5010004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <Narendra_K@Dell.com>, <bjorn@mork.no>, <netdev@vger.kernel.org>,
	<yoshfuji@linux-ipv6.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47543 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156Ab3FGPYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 11:24:04 -0400
In-Reply-To: <51B1F1FF.5010004@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-07 at 07:45 -0700, John Fastabend wrote:
> On 5/31/2013 5:17 AM, Narendra_K@Dell.com wrote:
> > On Thu, May 30, 2013 at 07:08:46PM +0530, Bj=C3=B8rn Mork wrote:
> >>
> >> <Narendra_K@Dell.com> writes:
> >>
> >>> From: Narendra K <narendra_k@dell.com>
> >>>
> >>> 'dev_id' sysfs attribute is initialized to zero by default.
> >>> It is also zero based. This creates ambiguity in differentiating
> >>> whether the driver set it to zero or it is the default value.
> >>> Initialize 'dev_id' to -1 to make the scenario unambiguous.
> >>
> >> I understand your concern, but I don't think you can do this.  It
> >> changes the userspace API, and has some very visible side effects.
> >>
> >> Please take a look at net/ipv6/addrconf.c
> >
> > Ok, thank you for pointing it. I missed it while looking for its
> > possible use scenarios.
>=20
> Although I'm not sure how that check works with devices that are
> setting dev_id and also provide their own mac addresses. From
> inspection it looks like these devices end up with a local interface
> identifier unnecessarily.
>=20
> Maybe Ben knows one of the drivers is the siena solorflare controller
> apparently for the SFC9000 family? The other two 'grep' finds are
> an mlx and chelsio device.
>=20
> Interestingly I didn't find any devices setting dev_id that also
> didn't program unique mac addresses. Perhaps I'm missing something?

I set this for Siena so that userland can tell which PF and port is
which even if the PCIe topology is hidden by virtualisation.  In
practice we haven't made use of that (and since virtualisation may also
hide the VPD and serial number capabilities, it probably doesn't help
much).

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
