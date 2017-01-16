From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v4 5/6] virtio: add pci_down/pci_up configuration
Date: Mon, 16 Jan 2017 11:57:24 +0800
Message-ID: <8844bce3-74bc-fca3-a87b-6736fc62fe62@redhat.com>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
 <20170116000119.28980.89712.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58924 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750840AbdAPD5d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Jan 2017 22:57:33 -0500
In-Reply-To: <20170116000119.28980.89712.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月16日 08:01, John Fastabend wrote:
> In virtio_net we need to do a full reset of the device to support
> queue reconfiguration and also we can trigger this via ethtool
> commands. So instead of open coding this in net driver push this
> into generic code in virtio. This also avoid exporting a handful
> of internal virtio routines.

Looks like this is not a pci specific stuffs. And there's some driver 
left (e.g scsi and block).

In fact, I'm not sure touching other drivers is really needed. Maybe we 
can just:
- move virtio_device_freeze(), virtio_device_restore() and 
.freeze/.restore in virtio_driver out of CONFIG_PM_SLEEP
- move virtnet_freeze() and virtnet_restore() out of CONFIG_PM_SLEEP
- introduce virtio_net_reset() and call 
virtio_device_freeze()/virtio_device_restore() there

Another possible issue for sleep/hibernation is xdp_prog were not 
restored, if this is not XDP intended, we'd better fix this.

Thanks

[...]
