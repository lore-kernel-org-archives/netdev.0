From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: use safer way to lock all
 buckets
Date: Thu, 14 Jan 2016 15:14:04 +0100
Message-ID: <20160114151404.729efbd2@redhat.com>
References: <1451960746-28915-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451960746-28915-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  4 Jan 2016 21:25:46 -0500
Sasha Levin <sasha.levin@oracle.com> wrote:

> When we need to lock all buckets in the connection hashtable we'd attempt to
> lock 1024 spinlocks, which is way more preemption levels than supported by
> the kernel. Furthermore, this behavior was hidden by checking if lockdep is
> enabled, and if it was - use only 8 buckets(!).
> 
> Fix this by using a global lock and synchronize all buckets on it when we
> need to lock them all. This is pretty heavyweight, but is only done when we
> need to resize the hashtable, and that doesn't happen often enough (or at all).
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---

Looks good to me, and I like the idea.

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
