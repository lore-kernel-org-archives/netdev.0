From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2] iov_iter: don't revert iov buffer if csum error
Date: Sat, 29 Apr 2017 03:46:47 +0100
Message-ID: <20170429024647.GO29622@ZenIV.linux.org.uk>
References: <d1ef9185-0956-aed9-e44b-84458cf28764@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pabeni@redhat.com,
        edumazet@google.com, hannes@stressinduktion.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56290 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936258AbdD2CrI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 22:47:08 -0400
Content-Disposition: inline
In-Reply-To: <d1ef9185-0956-aed9-e44b-84458cf28764@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 29, 2017 at 10:38:48AM +0800, Ding Tianhong wrote:
> The patch 327868212381 (make skb_copy_datagram_msg() et.al. preserve
> ->msg_iter on error) will revert the iov buffer if copy to iter
> failed, but it didn't copy any datagram if the skb_checksum_complete
> error, so no need to revert any data at this place.

The bug is real, but I would suggest a simpler fix:
                if (__skb_checksum_complete(skb))
                        return -EINVAL;
leaving the rest as-is.
