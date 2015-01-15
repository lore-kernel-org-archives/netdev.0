From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/5] vxlan: Group Policy extension
Date: Thu, 15 Jan 2015 03:20:28 +0000
Message-ID: <20150115032028.GA29974@casper.infradead.org>
References: <cover.1421290198.git.tgraf@suug.ch>
 <80677f296e829f43ca57a4c0dc4f45782e2e6f8e.1421290198.git.tgraf@suug.ch>
 <CA+mtBx9QV89vb+kwY4PUnemwqq-vWgpU4paDEs0FjYVDS2MsXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35346 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbbAODUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 22:20:30 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx9QV89vb+kwY4PUnemwqq-vWgpU4paDEs0FjYVDS2MsXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 07:06pm, Tom Herbert wrote:
> > +struct vxlan_metadata {
> > +       __be32          vni;
> > +       u32             gbp;
> 
> Should this be __be32 also and use ntohl/htonl when setting to/from skb->mark?

The bitmask is stored in host byte order in vxlan_metadata to be
compatible with skb->mark and converted to network byte order on
the wire, see:

        gbp = (struct vxlanhdr_gbp *)vxh;
        md.gbp = ntohs(gbp->policy_id);

and:

	gbp->policy_id = htons(md->gbp & VXLAN_GBP_ID_MASK);
