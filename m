From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: XDP_DROP and XDP_TX (Was: Re: [net-next PATCH v5 0/6] XDP for
 virtio_net)
Date: Tue, 13 Dec 2016 09:46:01 +0100
Message-ID: <20161213094601.7098090e@redhat.com>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
        <20161208.141702.1346950420275854265.davem@davemloft.net>
        <20161208193814.GA1954@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, john.fastabend@gmail.com,
        daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        tgraf@suug.ch, john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53606 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752495AbcLMIqI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 03:46:08 -0500
In-Reply-To: <20161208193814.GA1954@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 8 Dec 2016 11:38:16 -0800
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> On Thu, Dec 08, 2016 at 02:17:02PM -0500, David Miller wrote:
> > From: John Fastabend <john.fastabend@gmail.com>
> > Date: Wed, 07 Dec 2016 12:10:47 -0800
> >   
[...]
> > > Can't we disable XDP_TX somehow? Many people might only want RX drop,
> > > and extra queues are not always there.
> > >  
> > 
> > Alexei, Daniel, any thoughts on this?  
> 
> I don't like it.

I don't know that the use-case virtio XDP_TX is, but I still think we
should implement it for this virtio_net driver, as it allow easier
testing of XDP programs without physical HW.

BUT I do believe XDP_DROP and XDP_TX should be two different capabilities.

I can easily imagine that an older driver only wants to implement the
XDP_DROP facility. The reason is that XDP_TX would require changing too
much driver code, which is a concern for an old, stable and time-proven
driver.

I can also imagine wanting to implement XDP_DROP on my OpenWRT home
router, which I don't think can get an extra HW TX queue for XDP_TX.

I even have a practical use-case for my OpenWRT home router.  I
experience a Windows machine being connected to my home network, it
caused some (WiFi) traffic storm that overloaded the small OpenWRT box,
so much that it couldn't even route packets for other machines
connected (on Ethernet).  This could also be an IoT device or an
infected machine participating in a DDoS attack.  I fairly quickly
identified the bad machine and disconnected it from the network, but
for e.g. conference or hotel networks is can be harder to identify and
disconnect offenders.  An XDP eBPF (ddos) filter could allow the sysadm
to "virtually" disconnect a certain MAC address, and restore operation.


> > I know we were trying to claim some base level of feature support for
> > all XDP drivers. I am sympathetic to this argument though for DDOS we
> > do not need XDP_TX support. And virtio can become queue constrained
> > in some cases.  
> 
> Without XDP_TX it's too crippled. adjust_head() won't be possible,
> packet mangling would have to be disabled and so on.

Even without XDP_TX support, adjust_head() must be supported.  The
XDP_PASS action still requires ability to modify the packet.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
