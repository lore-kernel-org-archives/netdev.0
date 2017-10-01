From: Fengguang Wu <lkp@intel.com>
Subject: Re: [kbuild-all] [PATCH net-next] vhost_net: do not stall on
 zerocopy depletion
Date: Sun, 1 Oct 2017 11:26:55 +0800
Message-ID: <20171001032655.7tuk6qcrd2awtwbe@wfg-t540p.sh.intel.com>
References: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com>
 <201710010753.KeY9a5xF%fengguang.wu@intel.com>
 <20171001062018-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org, jasowang@redhat.com,
        Willem de Bruijn <willemb@google.com>, den@klaipeden.com,
        virtualization@lists.linux-foundation.org, kbuild-all@01.org,
        davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:1568 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750730AbdJAD06 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 30 Sep 2017 23:26:58 -0400
Content-Disposition: inline
In-Reply-To: <20171001062018-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 01, 2017 at 06:20:49AM +0300, Michael S. Tsirkin wrote:
>On Sun, Oct 01, 2017 at 08:09:30AM +0800, kbuild test robot wrote:
>> Hi Willem,
>>
>> [auto build test WARNING on net-next/master]
>>
>> url:    https://github.com/0day-ci/linux/commits/Willem-de-Bruijn/vhost_net-do-not-stall-on-zerocopy-depletion/20171001-054709
>> reproduce:
>>         # apt-get install sparse
>>         make ARCH=x86_64 allmodconfig
>>         make C=1 CF=-D__CHECK_ENDIAN__
>
>BTW __CHECK_ENDIAN__ is the default now, I think you can drop it from
>your scripts.

Good tip, thank you! However since we're testing old kernels, too,
we'll need to keep it for probably 1-3 more years.

Thanks,
Fengguang

>>
>> sparse warnings: (new ones prefixed by >>)
>>
>>
>> vim +440 drivers/vhost/net.c
>>
>>    433	
>>    434	static bool vhost_exceeds_maxpend(struct vhost_net *net)
>>    435	{
>>    436		struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
>>    437		struct vhost_virtqueue *vq = &nvq->vq;
>>    438	
>>    439		return (nvq->upend_idx + UIO_MAXIOV - nvq->done_idx) % UIO_MAXIOV >
>>  > 440		       min(VHOST_MAX_PEND, vq->num >> 2);
>>    441	}
>>    442	
>>
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology Center
>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>_______________________________________________
>kbuild-all mailing list
>kbuild-all@lists.01.org
>https://lists.01.org/mailman/listinfo/kbuild-all
