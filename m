From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next] net-ethtool: Allow ethtool to set interface
	in loopback mode.
Date: Tue, 29 Mar 2011 15:39:41 +0200
Message-ID: <20110329133941.GA15944@rere.qmqm.pl>
References: <1301351066-24916-1-git-send-email-maheshb@google.com> <1301356123.27727.41.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60320 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab1C2Njn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 09:39:43 -0400
Content-Disposition: inline
In-Reply-To: <1301356123.27727.41.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2011 at 12:48:43AM +0100, Ben Hutchings wrote:
> I'm sorry that things keep changing under your feet.  Unfortunately I=
'm
> going to have to ask for more changes; see below.
>=20
> I'm cc'ing Micha=B3 Miros=B3aw so he can comment on how he thinks the
> generic feature handling should be extended.
>=20
> On Mon, 2011-03-28 at 15:24 -0700, Mahesh Bandewar wrote:
> > Add second word for feature (currently it's single word). Also use =
the first
> > bit of the second word to set the loopback mode. By configuring the=
 interface
> > in loopback mode in conjunction with a policy route / rule, a user-=
land
> > application can stress the egress / ingress path exposing the flows=
 of the
> > change in progress and potentially help developer(s) understand the=
 impact of
> > those changes without even sending a packet out on the network.

=46or one, adding more feature words should be separate patch to the on=
e
introducing loopback mode.

Unless I missed some patches, there's still one or two bits left in fea=
tures
you can use. This will be a lot less work for you.

As Ben already commented on the visible parts of the patch, I'll only a=
dd
what's missing in it.

Extending feature words will need at least:
 - adding new features word (making it an array will be a big patch unl=
ess
   it's doable with preprocessor hackery)
 - changing hw_features and wanted_features to arrays
 - extending ndo_fix/set_features to handle arrays instead of one word
 - updating bridge/vlan/bonding code to handle propagation of the extra=
 words
   (I'm waiting for merge window to close to resend patches touching th=
is
   for proper review)
 - extending netdev_features_strings[] to 32x count of words (or functi=
ons
   using it could be modified to handle missing entries at the end)

Best Regards,
Micha=B3 Miros=B3aw
