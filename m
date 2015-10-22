From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: sock_put wasn't safe to call in interrupt
 context
Date: Thu, 22 Oct 2015 07:21:39 -0700 (PDT)
Message-ID: <20151022.072139.454804647788377055.davem@davemloft.net>
References: <1445428436-52369-1-git-send-email-jhansen@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, pv-drivers@vmware.com
To: jhansen@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445428436-52369-1-git-send-email-jhansen@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jorgen Hansen <jhansen@vmware.com>
Date: Wed, 21 Oct 2015 04:53:56 -0700

> In the vsock vmci_transport driver, sock_put wasn't safe to call
> in interrupt context, since that may call the vsock destructor
> which in turn calls several functions that should only be called
> from process context. This change defers the callling of these
> functions  to a worker thread. All these functions were
> deallocation of resources related to the transport itself.
> 
> Furthermore, an unused callback was removed to simplify the
> cleanup.
> 
> Multiple customers have been hitting this issue when using
> VMware tools on vSphere 2015.
> 
> Also added a version to the vmci transport module (starting from
> 1.0.2.0-k since up until now it appears that this module was
> sharing version with vsock that is currently at 1.0.1.0-k).
> 
> Reviewed-by: Aditya Asarwade <asarwade@vmware.com>
> Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
> Signed-off-by: Jorgen Hansen <jhansen@vmware.com>

Applied, thanks.
