From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [RFC PATCH 3/7] net: add option to get information about
 timestamped packets
Date: Thu, 13 Apr 2017 17:18:06 +0200
Message-ID: <20170413151806.GA26613@localhost>
References: <20170412141737.5881-1-mlichvar@redhat.com>
 <20170412141737.5881-4-mlichvar@redhat.com>
 <CAF=yD-Lsbr7f7aPUsFF3gCtFdyR8yb1=VBPJGQuxv_JbrJud6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35068 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751666AbdDMPSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 11:18:09 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-Lsbr7f7aPUsFF3gCtFdyR8yb1=VBPJGQuxv_JbrJud6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 10:37:07AM -0400, Willem de Bruijn wrote:
> On Wed, Apr 12, 2017 at 10:17 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > Extend the skb_shared_hwtstamps structure with the index of the
> > real interface which received or transmitted the packet and the length
> > of the packet at layer 2.
> 
> The original packet is received along with the timestamp.

But only outgoing packets, right?

> Why is this L2 length needed?

It's needed for incoming packets to allow converting of preamble
timestamps to trailer timestamps.

> > Add a SOF_TIMESTAMPING_OPT_PKTINFO flag to
> > the SO_TIMESTAMPING option to allow applications to get this information
> > as struct scm_ts_pktinfo in SCM_TIMESTAMPING_PKTINFO control message.
> 
> This patch saves skb->dev->ifindex, which is the same as existing
> SOF_TIMESTAMPING_OPT_CMSG. See also the bug fix for that
> feature I sent yesterday: http://patchwork.ozlabs.org/patch/750197/

The main point is that it provides the index of the device which
received the packet. It does duplicate the functionality of OPT_CMSG +
IP_PKTINFO for outgoing packets, but I thought it might be useful with
the TSONLY option.

BTW, the original ifindex used to be in skb->skb_iif, but that changed
in b6858177.

> If the intent is to return a different ifindex, I would still suggest using
> the existing pktinfo infrastructure, but changing the ifindex that is
> recorded.

How would the application get the l2 length? If this (l2 length,
if_index) tuple is specific to timestamping, I think it would make
sense to keep it out of the IP layer.

-- 
Miroslav Lichvar
