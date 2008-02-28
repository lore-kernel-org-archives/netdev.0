From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/15] [8021Q]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 14:15:19 -0800 (PST)
Message-ID: <20080228.141519.48676600.davem@davemloft.net>
References: <47C693D0.3090007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760690AbYB1WPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:15:20 -0500
In-Reply-To: <47C693D0.3090007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:58:24 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.

> @@ -182,13 +181,11 @@ int vlan_proc_add_dev(struct net_device *vlandev)
>  {
>  	struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
>  
> -	dev_info->dent = create_proc_entry(vlandev->name,
> -					   S_IFREG|S_IRUSR|S_IWUSR,
> -					   proc_vlan_dir);
> +	dev_info->dent = proc_create(vlandev->name, S_IFREG|S_IRUSR|S_IWUSR,
> +				     proc_vlan_dir, &vlandev_fops);
>  	if (!dev_info->dent)
>  		return -ENOBUFS;
>  
> -	dev_info->dent->proc_fops = &vlandev_fops;
>  	dev_info->dent->data = vlandev;
>  	return 0;
>  }

->data visibility issue
