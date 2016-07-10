From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [ovs-dev] [PATCH net-next v11 4/6] openvswitch: add support to
 push and pop mpls for layer3 packets
Date: Sun, 10 Jul 2016 20:14:34 +0900
Message-ID: <20160710111433.GA21932@penelope.isobedori.kobe.vergenet.net>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
 <1467827996-32547-5-git-send-email-simon.horman@netronome.com>
 <CAOrHB_C8Z5zQ6NMm-VMpd2czr=aRJ8p=XZK5YY_B8OAhUkXdGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34578 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbcGJLOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 07:14:40 -0400
Received: by mail-pa0-f45.google.com with SMTP id fi15so12590669pac.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 04:14:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_C8Z5zQ6NMm-VMpd2czr=aRJ8p=XZK5YY_B8OAhUkXdGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 01:52:47PM -0700, pravin shelar wrote:
> On Wed, Jul 6, 2016 at 10:59 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Allow push and pop mpls actions to act on layer 3 packets by teaching
> > them not to access non-existent L2 headers of such packets.
> >
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> > v11
> > * group l2 code in pop_mpls()
> >
> > v10
> > * Limit scope of hdr in {push,pop}_mpls()
> >
> > v9
> > * New Patch
> > ---
> >  include/uapi/linux/openvswitch.h |  2 ++
> >  net/openvswitch/actions.c        | 24 +++++++++++++++---------
> >  2 files changed, 17 insertions(+), 9 deletions(-)
> >
> > diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> > index d95a3018f6a1..5cde501433eb 100644
> > --- a/include/uapi/linux/openvswitch.h
> > +++ b/include/uapi/linux/openvswitch.h
> > @@ -737,6 +737,8 @@ enum ovs_nat_attr {
> >   * is no MPLS label stack, as determined by ethertype, no action is taken.
> >   * @OVS_ACTION_ATTR_CT: Track the connection. Populate the conntrack-related
> >   * entries in the flow key.
> > + * @OVS_ACTION_ATTR_PUSH_ETH: Push a new outermost Ethernet header onto the      * packet.
> > + * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the packet.
> >   *
> >   * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
> >   * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
> 
> This hunk is not related to this patch.

Sorry about that, I will move it.

> > diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> > index 1ecbd7715f6d..12e8a8942a42 100644
> > --- a/net/openvswitch/actions.c
> > +++ b/net/openvswitch/actions.c
> ...
