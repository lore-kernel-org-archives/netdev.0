From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH 1/2] virtio_net: cap mtu when XDP programs are running
Date: Thu, 5 Jan 2017 17:34:05 +0800
Message-ID: <9aa07031-8c09-dbeb-c7ed-41daf5866be2@redhat.com>
References: <20170105031118.2636.82374.stgit@john-Precision-Tower-5810>
 <20170105051641-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35724 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970379AbdAEJe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 04:34:29 -0500
In-Reply-To: <20170105051641-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月05日 11:18, Michael S. Tsirkin wrote:
> On Wed, Jan 04, 2017 at 07:11:18PM -0800, John Fastabend wrote:
>> XDP programs can not consume multiple pages so we cap the MTU to
>> avoid this case. Virtio-net however only checks the MTU at XDP
>> program load and does not block MTU changes after the program
>> has loaded.
> Do drivers really have to tweak max mtu all the time?
> Seems strange, I would say drivers just report device caps
> and net core enforces rules.
> Can't net core do these checks?

I think this needs host co-operation, at least this patch prevents user 
from misconfiguring mtu in guest.
