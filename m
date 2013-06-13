From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] macvlan: don't touch promisc without passthrough
Date: Thu, 13 Jun 2013 01:20:55 -0700 (PDT)
Message-ID: <20130613.012055.1850149112448977565.davem@davemloft.net>
References: <1371107001-10250-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, john.r.fastabend@intel.com,
	kaber@trash.net, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371107001-10250-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 13 Jun 2013 10:07:29 +0300

> commit df8ef8f3aaa6692970a436204c4429210addb23a
> "macvlan: add FDB bridge ops and macvlan flags"
> added a way to control NOPROMISC macvlan flag through netlink.
> 
> However, with a non passthrough device we never set promisc on open,
> even if NOPROMISC is off.  As a result:
> 
> If userspace clears NOPROMISC on open, then does not clear it on a
> netlink command, promisc counter is not decremented on stop and there
> will be no way to clear it once macvlan is detached.
> 
> If userspace does not clear NOPROMISC on open, then sets NOPROMISC on a
> netlink command, promisc counter will be decremented from 0 and overflow
> to fffffffff with no way to clear promisc.
> 
> To fix, simply ignore NOPROMISC flag in a netlink command for
> non-passthrough devices, same as we do at open/close.
> 
> Since we touch this code anyway - check dev_set_promiscuity return code
> and pass it to users (though an error here is unlikely).
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks.
