From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 11/15] i40e: debugfs command to change RSS queue count
Date: Thu, 12 Dec 2013 20:41:15 +0000
Message-ID: <1386880875.1516.317.camel@bwh-desktop.uk.level5networks.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1386852051-27907-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44477 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab3LLUlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 15:41:19 -0500
In-Reply-To: <1386852051-27907-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 04:40 -0800, Jeff Kirsher wrote:
> From: Anjali Singhai Jain <anjali.singhai@intel.com>
> 
> This is the 3rd of 3 patches that implements changing the number
> of queues on the fly.
> 
> This patch adds the debugfs hook for calling the change queues
> flow with a request to change the number of RSS queues.
> 
> This is intended to also be called eventually from ethtool.

The ethtool set_channels operation is implemented in 12/15, so why
include this awful interface as well?

Ben.

> Change-Id: Ib6b332f0ec8e58989ef8c65ec30079d01fdf6c9a
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> index 9c675b5..3303b43 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> @@ -1792,6 +1792,17 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
>  		}
>  		kfree(buff);
>  		buff = NULL;
> +	} else if (strncmp(cmd_buf, "set rss_size", 12) == 0) {
> +		u16 queue_count;
> +		cnt = sscanf(&cmd_buf[12], "%hi", &queue_count);
> +		if (cnt != 1) {
> +			dev_info(&pf->pdev->dev,
> +				 "set rss_size: bad command string, cnt=%d\n", cnt);
> +			goto command_write_done;
> +		}
> +		dev_info(&pf->pdev->dev, " set rss_size requesting %d queues\n", queue_count);
> +		i40e_reconfig_rss_queues(pf, queue_count);
> +		dev_info(&pf->pdev->dev, " new rss_size %d\n", pf->rss_size);
>  	} else {
>  		dev_info(&pf->pdev->dev, "unknown command '%s'\n", cmd_buf);
>  		dev_info(&pf->pdev->dev, "available commands\n");
> @@ -1827,6 +1838,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
>  		dev_info(&pf->pdev->dev, "  lldp event on\n");
>  		dev_info(&pf->pdev->dev, "  lldp event off\n");
>  		dev_info(&pf->pdev->dev, "  nvm read [module] [word_offset] [word_count]\n");
> +		dev_info(&pf->pdev->dev, "  set rss_size <count>\n");
>  	}
>  
>  command_write_done:

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
