From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 7/8] openvswitch: Drop user features if old user
 space attempted to create datapath
Date: Wed, 27 Nov 2013 22:35:12 +0000
Message-ID: <20131127223512.GB26084@casper.infradead.org>
References: <cover.1385137618.git.tgraf@suug.ch>
 <a207b27c2830c9098045455808e1ca6d203a5d9a.1385137618.git.tgraf@suug.ch>
 <CAEP_g=8nADwqAJ81gtpJ-6v2XW4Se+OK1RPcEZ7mh-_PAwyo7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48804 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755397Ab3K0WfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 17:35:14 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=8nADwqAJ81gtpJ-6v2XW4Se+OK1RPcEZ7mh-_PAwyo7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/13 at 03:40pm, Jesse Gross wrote:
> On Fri, Nov 22, 2013 at 8:56 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> > index 07ef2c3..a6863e2 100644
> > --- a/include/uapi/linux/openvswitch.h
> > +++ b/include/uapi/linux/openvswitch.h
> > @@ -40,7 +40,15 @@ struct ovs_header {
> >
> >  #define OVS_DATAPATH_FAMILY  "ovs_datapath"
> >  #define OVS_DATAPATH_MCGROUP "ovs_datapath"
> > -#define OVS_DATAPATH_VERSION 0x1
> > +
> > +/* V2:
> > + *   - API users are expected to provide OVS_DP_ATTR_USER_FEATURES
> > + *     with NLM_F_REPLACE when creating the datapath.
> > + */
> > +#define OVS_DATAPATH_VERSION 2
> 
> I'm not sure that I understand this comment - I guess it means that
> there's no legacy path when using NLM_F_REPLACE?

It means that if the V2 caller does not provide user features the
existing user features are preserved upon NLM_F_REPLACE. V1 users
can't be aware and the user features are always reset.
