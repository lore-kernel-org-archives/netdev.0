From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 02/12] selinux: tag avc cache alloc as non-critical
Date: Thu, 10 May 2012 07:14:45 -0700
Message-ID: <4FABCD55.9000504@schaufler-ca.com>
References: <1336658065-24851-1-git-send-email-mgorman@suse.de> <1336658065-24851-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	Linux-NFS <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric B Munson <emunson@mgebm.net>,
	LSM <linux-security-module@vger.kernel.org>,
	SE Linux <selinux@tycho.nsa.gov>
To: Mel Gorman <mgorman@suse.de>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1336658065-24851-3-git-send-email-mgorman@suse.de>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/10/2012 6:54 AM, Mel Gorman wrote:
> Failing to allocate a cache entry will only harm performance not
> correctness.  Do not consume valuable reserve pages for something
> like that.

Copying to the LSM and SELinux lists.
 
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  security/selinux/avc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/security/selinux/avc.c b/security/selinux/avc.c
> index 8ee42b2..75c2977 100644
> --- a/security/selinux/avc.c
> +++ b/security/selinux/avc.c
> @@ -280,7 +280,7 @@ static struct avc_node *avc_alloc_node(void)
>  {
>  	struct avc_node *node;
>  
> -	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
> +	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
>  	if (!node)
>  		goto out;
>  

