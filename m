From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/6] openvswitch: Allow for any level of nesting in flow
 attributes
Date: Mon, 12 Jan 2015 23:04:38 +0000
Message-ID: <20150112230438.GE11857@casper.infradead.org>
References: <cover.1421064100.git.tgraf@suug.ch>
 <793586e5305017d914913df4d3502cada6f1f55f.1421064100.git.tgraf@suug.ch>
 <CAEP_g=9ArL-qy1vU=E0ATxHAs0GN5mUzNNbHFBXsf-_083qcOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48153 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbbALXEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 18:04:40 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=9ArL-qy1vU=E0ATxHAs0GN5mUzNNbHFBXsf-_083qcOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 11:41am, Jesse Gross wrote:
> On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > +       [OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS]   = { .len = OVS_ATTR_NESTED },
> > +};
> 
> Geneve isn't really nested - maybe we should break it out into a
> separate name? OVS_ATTR_VARIABLE? We shouldn't really try to traverse
> it as netlink attributes anyways.

Agreed. I inteionally kept the behaviour intact in this series and was
about to do fix this in a separate patch to not make this series any
more complex than it already is ;-)

> > +static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
> > +       [OVS_KEY_ATTR_ENCAP]     = { .len = OVS_ATTR_NESTED },
> 
> This is not new but I think that encap isn't really handled correctly.
> In theory, there could be multiple levels of nesting here (either
> another encap or some other element) but there's no 'next' link.
> However, I don't believe the situation arises today.

Right. The behaviour is identical as before the patch. I just replaced
the -1 with a name. Agreed that we should clean this up 
