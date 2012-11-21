From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [net-next 06/10] ixgbe: eliminate Smatch warnings in
 ixgbe_debugfs.c
Date: Wed, 21 Nov 2012 14:04:09 +0300
Message-ID: <20121121110409.GG6186@mwanda>
References: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1353494856-12344-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Josh Hay <joshua.a.hay@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45641 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789Ab2KULEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 06:04:31 -0500
Content-Disposition: inline
In-Reply-To: <1353494856-12344-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 21, 2012 at 02:47:32AM -0800, Jeff Kirsher wrote:
> +	len = simple_write_to_buffer(ixgbe_dbg_reg_ops_buf,
> +				     sizeof(ixgbe_dbg_reg_ops_buf)-1,
> +				     ppos,
> +				     buffer,
> +				     count);
> +	if (len < 0)
> +		return -EFAULT;

Any negative return is bad.

	if (len)
		return len;

> +
> +	ixgbe_dbg_reg_ops_buf[len] = '\0';
>  
>  	if (strncmp(ixgbe_dbg_reg_ops_buf, "write", 5) == 0) {
>  		u32 reg, value;
> @@ -187,15 +196,15 @@ static ssize_t ixgbe_dbg_netdev_ops_write(struct file *filp,
>  	if (count >= sizeof(ixgbe_dbg_netdev_ops_buf))
>  		return -ENOSPC;
>  
> -	bytes_not_copied = copy_from_user(ixgbe_dbg_netdev_ops_buf,
> -					  buffer, count);
> -	if (bytes_not_copied < 0)
> -		return bytes_not_copied;
> -	else if (bytes_not_copied < count)
> -		count -= bytes_not_copied;
> -	else
> -		return -ENOSPC;
> -	ixgbe_dbg_netdev_ops_buf[count] = '\0';
> +	len = simple_write_to_buffer(ixgbe_dbg_netdev_ops_buf,
> +				     sizeof(ixgbe_dbg_netdev_ops_buf)-1,
> +				     ppos,
> +				     buffer,
> +				     count);
> +	if (len < 0)
> +		return -EFAULT;

Same.

> +
> +	ixgbe_dbg_netdev_ops_buf[len] = '\0';

regards,
dan carpenter
