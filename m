From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tun driver not cleaning up on module remove
Date: Thu, 7 Aug 2003 15:59:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807155901.49f1a424.davem@redhat.com>
References: <200308051630.28552.bellucda@tiscali.it>
	<20030805090647.691daa7e.shemminger@osdl.org>
	<200308051910.55823.bellucda@tiscali.it>
	<20030807154524.4794ad45.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bellucda@tiscali.it, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030807154524.4794ad45.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Aug 2003 15:45:24 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This should fix module unload issues with tun driver in 2.6-test2.
> Driver was not cleaning up it's devices on module exit.

The fix looks correct, but the dev->init test looks kind of grotty.

Why not add a list_head to tun_struct, and then maintain a list rooted
in 'tun.c:tun_alldevs_list', then iterate over that in the
module_exit() routine?
