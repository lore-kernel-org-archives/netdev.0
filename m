From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH linux-3.10.y] ip6tnl: fix use after free of fb_tnl_dev
Date: Tue, 17 Dec 2013 11:54:53 -0800
Message-ID: <20131217195453.GB28274@kroah.com>
References: <20131212.153545.1184197791301496227.davem@davemloft.net>
 <1386925595-4995-1-git-send-email-nicolas.dichtel@6wind.com>
 <20131217.144002.1716319550180883592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	rostedt@goodmis.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, williams@redhat.com,
	linux-rt-users@vger.kernel.org, lclaudio@uudg.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131217.144002.1716319550180883592.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 17, 2013 at 02:40:02PM -0500, David Miller wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri, 13 Dec 2013 10:06:35 +0100
> 
> > The upstream commit bb8140947a24 ("ip6tnl: allow to use rtnl ops on fb tunnel")
> > (backported into linux-3.10.y) left a bug which was fixed upstream by commit
> > 1e9f3d6f1c40 ("ip6tnl: fix use after free of fb_tnl_dev").
> > 
> > The problem is a bit different in linux-3.10.y, because there is no x-netns
> > support (upstream commit 0bd8762824e7 ("ip6tnl: add x-netns support")).
> > When ip6_tunnel.ko is unloaded, FB device is deleted by rtnl_link_unregister()
> > and then we try to delete it again in ip6_tnl_destroy_tunnels().
> > 
> > This patch removes the second deletion.
> > 
> > Reported-by: Steven Rostedt <rostedt@goodmis.org>
> > Suggested-by: Steven Rostedt <rostedt@goodmis.org>
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Greg please queue this up for 3.10 -stable if you haven't already.

Thanks, will do.

greg k-h
