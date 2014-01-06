From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for
 macvtap
Date: Mon, 06 Jan 2014 15:47:40 -0500 (EST)
Message-ID: <20140106.154740.590358835696689785.davem@davemloft.net>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, john.r.fastabend@intel.com, nhorman@tuxdriver.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Mon,  6 Jan 2014 11:21:06 +0800

> L2 fowarding offload will bypass the rx handler of real device. This will make
> the packet could not be forwarded to macvtap device. Another problem is the
> dev_hard_start_xmit() called for macvtap does not have any synchronization.
> 
> Fix this by forbidding L2 forwarding for macvtap.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I think I agree with Neil that the rx_handler change might be the best
way to fix this.  That change seems to have a lot of nice unintended
side effects, no?
