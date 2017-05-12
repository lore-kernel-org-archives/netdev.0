From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen-netfront: avoid crashing on resume after a
 failure in talk_to_netback()
Date: Thu, 11 May 2017 21:39:12 -0400 (EDT)
Message-ID: <20170511.213912.1393187351699676007.davem@davemloft.net>
References: <20170511115806.25322-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com,
        jgross@suse.com
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170511115806.25322-1-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Thu, 11 May 2017 13:58:06 +0200

> Unavoidable crashes in netfront_resume() and netback_changed() after a
> previous fail in talk_to_netback() (e.g. when we fail to read MAC from
> xenstore) were discovered. The failure path in talk_to_netback() does
> unregister/free for netdev but we don't reset drvdata and we try accessing
> it after resume.
> 
> Fix the bug by removing the whole xen device completely with
> device_unregister(), this guarantees we won't have any calls into netfront
> after a failure.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> ---
> Changes since v1: instead of cleaning drvdata and checking for it in
> netfront_resume() and netback_changed() remove the device completely with
> device_unregister() [David Miller]

This looks a lot better, applied, thanks!
