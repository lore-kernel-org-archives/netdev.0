From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [RFC PATCH 3/7] net: add option to get information about
 timestamped packets
Date: Thu, 13 Apr 2017 10:37:07 -0400
Message-ID: <CAF=yD-Lsbr7f7aPUsFF3gCtFdyR8yb1=VBPJGQuxv_JbrJud6Q@mail.gmail.com>
References: <20170412141737.5881-1-mlichvar@redhat.com> <20170412141737.5881-4-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:36093 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752446AbdDMOhy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 10:37:54 -0400
Received: by mail-qt0-f182.google.com with SMTP id v3so47222842qtd.3
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 07:37:48 -0700 (PDT)
In-Reply-To: <20170412141737.5881-4-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 10:17 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> Extend the skb_shared_hwtstamps structure with the index of the
> real interface which received or transmitted the packet and the length
> of the packet at layer 2.

The original packet is received along with the timestamp. Why is this L2
length needed?

> Add a SOF_TIMESTAMPING_OPT_PKTINFO flag to
> the SO_TIMESTAMPING option to allow applications to get this information
> as struct scm_ts_pktinfo in SCM_TIMESTAMPING_PKTINFO control message.

This patch saves skb->dev->ifindex, which is the same as existing
SOF_TIMESTAMPING_OPT_CMSG. See also the bug fix for that
feature I sent yesterday: http://patchwork.ozlabs.org/patch/750197/

If the intent is to return a different ifindex, I would still suggest using
the existing pktinfo infrastructure, but changing the ifindex that is
recorded.
