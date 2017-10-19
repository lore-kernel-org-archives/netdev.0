From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/5] net: virtio dynamically disable/enable LRO
Date: Thu, 19 Oct 2017 05:47:30 +0300
Message-ID: <20171019054432-mutt-send-email-mst@kernel.org>
References: <CA+7y87rYzKSDLb-wq9ok8TqgD_41u8oqZvfWLELYgDqQ4wCrKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, tgraf@suug.ch,
        shm@cumulusnetworks.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, davem@davemloft.net, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com,
        Catherine Sullivan <csully@google.com>,
        Jason Wang <jasowang@redhat.com>
To: Caleb Raitto <caraitto@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42930 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751264AbdJSCrg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 22:47:36 -0400
Content-Disposition: inline
In-Reply-To: <CA+7y87rYzKSDLb-wq9ok8TqgD_41u8oqZvfWLELYgDqQ4wCrKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 07:18:31PM -0700, Caleb Raitto wrote:
> On Fri, Nov 18, 2016 at 11:00 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
> >
> > From: John Fastabend <john.fastabend@gmail.com>
> > Date: Fri, Nov 18, 2016 at 11:00 AM
> > Subject: [PATCH 1/5] net: virtio dynamically disable/enable LRO
> > To: <tgraf@suug.ch>, <shm@cumulusnetworks.com>, <alexei.starovoitov@gmail.com>, <daniel@iogearbox.net>, <davem@davemloft.net>
> > Cc: <john.r.fastabend@intel.com>, <netdev@vger.kernel.org>, <bblanco@plumgrid.com>, <john.fastabend@gmail.com>, <brouer@redhat.com>
> >
> > This adds support for dynamically setting the LRO feature flag. The
> > message to control guest features in the backend uses the
> > CTRL_GUEST_OFFLOADS msg type.
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > ---
> >  drivers/net/virtio_net.c |   43 +++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 43 insertions(+)
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index 2cafd12..0758cae 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -1419,6 +1419,41 @@ static void virtnet_init_settings(struct net_device *dev)
> 
> Hi,
> 
> I work on Google Compute Engine, and I noticed that you had this
> unmerged patch that allows controlling offloads using ethtool for
> virtionet.
> 
> We are interested in merging this patch as it will be useful in
> debugging customer issues related to offloads and MTU.
> 
> If work remains to get the patch merged, I'm willing to help out.
> 
> Thanks,
> -Caleb

This patch needs to be rebased on top of latest patches by Jason.
In particular, there's code to disable/enable offloads automatically.
That either needs to go away if user configured them manually,
or the conflict resolved.

-- 
MST
