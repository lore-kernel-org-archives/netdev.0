From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Wed, 26 Oct 2016 15:52:02 +0200
Message-ID: <20161026155202.5d99d935@redhat.com>
References: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, mst@redhat.com, tom@herbertland.com,
        netdev@vger.kernel.org, shm@cumulusnetworks.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shrijeet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933484AbcJZNwI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 09:52:08 -0400
In-Reply-To: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Oct 2016 04:07:23 +0000
Shrijeet Mukherjee <shrijeet@gmail.com> wrote:

> This patch adds support for xdp ndo and also inserts the xdp program
> call into the merged RX buffers and big buffers paths

I really appreciate you are doing this for virtio_net.

My first question is: Is the (packet) page data writable?
(MST might be able to answer?)

As this is currently an XDP requirement[1].  


> * The small packet skb receive is skipped for now
> * No TX for now

I do see more and more valid use-cases for only implementing XDP_DROP
and not necessarily also implementing XDP_TX.  This does requires that
we implement some kind of feature/capabilities negotiation mechanism[2].


[1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/requirements.html#write-access-to-packet-data

[2] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/design.html#capabilities-negotiation

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
