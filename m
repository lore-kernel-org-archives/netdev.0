From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/5] vxlan: Group Policy extension
Date: Thu, 15 Jan 2015 00:23:23 +0000
Message-ID: <20150115002323.GH2105@casper.infradead.org>
References: <cover.1421280226.git.tgraf@suug.ch>
 <c73939bbb55a8e450de7931d830e0467a8340665.1421280226.git.tgraf@suug.ch>
 <CA+mtBx-CH2=D-wKmkjVTvhQOWhbf73NxcGrXrXOPE-E2PzJajQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.ne>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34497 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbbAOAXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 19:23:24 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx-CH2=D-wKmkjVTvhQOWhbf73NxcGrXrXOPE-E2PzJajQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 04:18pm, Tom Herbert wrote:
> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> > index 99df0d7..06f7196 100644
> > --- a/drivers/net/vxlan.c
> > +++ b/drivers/net/vxlan.c
> > @@ -126,6 +126,7 @@ struct vxlan_dev {
> >         __u8              tos;          /* TOS override */
> >         __u8              ttl;
> >         u32               flags;        /* VXLAN_F_* in vxlan.h */
> > +       u32               exts;         /* Enabled extensions */
> >
> 
> Thomas, why not just make a VXAM_F_GPB flag? Then this setting can be
> saved in the flags for vxlan_dev and vxlan_sock so no exts field.

Because we need to compare enabled extensions in vxlan_find_sock() to
make sure we are not sharing a VXLAN socket with extensions enabled
with a user which does not have the same extensions enabled.

However, we do not want vxlan_find_sock() to compare all flags.

So we need a bitmap that is ignored during the share check (flags) and
a bitmap that must match to allow sharing (exts).

The RCO extension is currently suffering from this bug which is causing
a compatibility issue. I explained in the thread of your patch. I was
under the imrpession that you would either send a v2 or fix it in a
follow-up.
