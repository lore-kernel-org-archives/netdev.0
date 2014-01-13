From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
 export mergeable rx buffer size
Date: Mon, 13 Jan 2014 15:38:08 +0000
Message-ID: <1389627488.2025.134.camel@bwh-desktop.uk.level5networks.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	 <1389072355-20666-4-git-send-email-mwdalton@google.com>
	 <52CCF177.7020500@redhat.com> <20140108192109.GC18312@redhat.com>
	 <CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
	 <20140112170939.GA17202@redhat.com>
	 <CANJ5vP+Vu8=haCetZkcefPgR8pGe0iDZ03EZhJHLSgunCaHJsQ@mail.gmail.com>
	 <20140113094018.GA22726@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>,
	Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Eric Dumazet" <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	lf-virt <virtualization@lists.linux-foundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49709 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbaAMPiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 10:38:13 -0500
In-Reply-To: <20140113094018.GA22726@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 11:40 +0200, Michael S. Tsirkin wrote:
> On Sun, Jan 12, 2014 at 03:32:28PM -0800, Michael Dalton wrote:
[...]
> > The last issue is how the rx_queue_attribute 'show' function
> > implementation for mergeable_rx_buffer_size will access the appropriate
> > per-receive queue EWMA data. The arguments to the show function will be
> > the netdev_rx_queue and the attribute itself. We can get to the
> > struct net_device from the netdev_rx_queue.  If we extended
> > netdev_rx_queue to indicate the queue_index or to store a void *priv_data
> > pointer, that would be sufficient to allow us to resolve this issue.
> 
> Hmm netdev_rx_queue is not defined unless CONFIG_RPS is set.
> Maybe we should use a different structure.
[...]

I don't think RPS should own this structure.  It's just that there are
currently no per-RX-queue attributes other than those defined by RPS.

By the way, CONFIG_RPS is equivalent to CONFIG_SMP so will likely be
enabled already in most places where virtio_net is used.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
