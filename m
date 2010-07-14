From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [2/5] Interrupt
 control bitmap
Date: Wed, 14 Jul 2010 14:04:33 -0700 (PDT)
Message-ID: <20100714.140433.59678649.davem@davemloft.net>
References: <alpine.LRH.2.00.1007070125440.4652@localhost.localdomain>
	<alpine.LRH.2.00.1007070222110.6105@localhost.localdomain>
	<alpine.LRH.2.00.1007131746370.32055@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, ronghua@vmware.com
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007131746370.32055@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Tue, 13 Jul 2010 17:48:04 -0700 (PDT)

> -	__le32		reserved[3];
> +	__le32		intrCtrl;
> +	__le32		reserved[2];
>  };
>  
 ...
> +	adapter->shared->devRead.intrConf.intrCtrl &= ~VMXNET3_IC_DISABLE_ALL;
 ...
> +	adapter->shared->devRead.intrConf.intrCtrl |= VMXNET3_IC_DISABLE_ALL;
 ...
> +	devRead->intrConf.intrCtrl |= VMXNET3_IC_DISABLE_ALL;

You need to use cpu_to_le32() and similar when accessing this value.

If you run "sparse" with endianness checking enabled you'll see
warnings showing alerting you to this issue...
