From: Petko Manolov <petkan@mip-labs.com>
Subject: Re: [PATCH] net: pegasus: Remove deprecated
 create_singlethread_workqueue
Date: Tue, 30 Aug 2016 19:41:48 +0300
Message-ID: <20160830164148.fz4tbei5g7dlma4n@p310>
References: <20160830163247.GA25925@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petko Manolov <petkan@nucleusys.com>, Tejun Heo <tj@kernel.org>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160830163247.GA25925@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-08-30 22:02:47, Bhaktipriya Shridhar wrote:
> The workqueue "pegasus_workqueue" queues a single work item per pegasus
> instance and hence it doesn't require execution ordering. Hence,
> alloc_workqueue has been used to replace the deprecated
> create_singlethread_workqueue instance.
> 
> The WQ_MEM_RECLAIM flag has been set to ensure forward progress under
> memory pressure since it's a network driver.
> 
> Since there are fixed number of work items, explicit concurrency
> limit is unnecessary here.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
> ---
>  drivers/net/usb/pegasus.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 9bbe0161..1434e5d 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -1129,7 +1129,8 @@ static int pegasus_probe(struct usb_interface *intf,
>  		return -ENODEV;
> 
>  	if (pegasus_count == 0) {
> -		pegasus_workqueue = create_singlethread_workqueue("pegasus");
> +		pegasus_workqueue = alloc_workqueue("pegasus", WQ_MEM_RECLAIM,
> +						    0);
>  		if (!pegasus_workqueue)
>  			return -ENOMEM;
>  	}
> --
> 2.1.4

Nope, there is no need for singlethread-ness here.  As long as the flag you used 
is doing the right thing i am OK with the patch.


		Petko
