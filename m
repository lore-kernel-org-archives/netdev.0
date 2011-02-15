From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] core: dev: don't call BUG() on bad input
Date: Tue, 15 Feb 2011 15:02:18 -0800
Message-ID: <20110215150218.65f64b3b@nehalam>
References: <1297680967-11893-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297680967-11893-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Feb 2011 13:56:06 +0300
Vasiliy Kulikov <segoon@openwall.com> wrote:

> alloc_netdev() may be called with too long name (more that IFNAMSIZ bytes).
> Currently this leads to BUG().  Other insane inputs (bad txqs, rxqs) and
> even OOM don't lead to BUG().  Made alloc_netdev() return NULL, like on
> other errors.

The only way alloc_netdev could be called with a name too long
was if some driver was incorrectly written. It is not something
that can be exercised by user space.

Please leave the BUG() so the driver will show up in
kernel oops logs etc.
