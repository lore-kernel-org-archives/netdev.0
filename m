From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v4 5/6] virtio: add pci_down/pci_up configuration
Date: Sun, 15 Jan 2017 20:04:30 -0800
Message-ID: <587C464E.6020407@gmail.com>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
 <20170116000119.28980.89712.stgit@john-Precision-Tower-5810>
 <8844bce3-74bc-fca3-a87b-6736fc62fe62@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35575 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdAPEEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 23:04:47 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so13225819pfa.2
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 20:04:47 -0800 (PST)
In-Reply-To: <8844bce3-74bc-fca3-a87b-6736fc62fe62@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-15 07:57 PM, Jason Wang wrote:
> 
> 
> On 2017年01月16日 08:01, John Fastabend wrote:
>> In virtio_net we need to do a full reset of the device to support
>> queue reconfiguration and also we can trigger this via ethtool
>> commands. So instead of open coding this in net driver push this
>> into generic code in virtio. This also avoid exporting a handful
>> of internal virtio routines.
> 
> Looks like this is not a pci specific stuffs. And there's some driver left (e.g
> scsi and block).
> 
> In fact, I'm not sure touching other drivers is really needed. Maybe we can just:
> - move virtio_device_freeze(), virtio_device_restore() and .freeze/.restore in
> virtio_driver out of CONFIG_PM_SLEEP
> - move virtnet_freeze() and virtnet_restore() out of CONFIG_PM_SLEEP
> - introduce virtio_net_reset() and call
> virtio_device_freeze()/virtio_device_restore() there
> 

Michael, what do you think? I was following your suggestion on writing a
generic virtio reset here. I don't have a preference either way.

> Another possible issue for sleep/hibernation is xdp_prog were not restored, if
> this is not XDP intended, we'd better fix this.

Yep this bug exists even without this series. I'll add it to my list of things
to fix. Along with small packet max_mtu.

> 
> Thanks
> 
> [...]
