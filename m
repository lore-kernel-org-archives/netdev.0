From: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Subject: Re: [atl1-devel] atl2: don't mess up irq on suspend/resume (probably
 msi only)
Date: Tue, 18 Nov 2008 14:30:45 +0000
Message-ID: <4922D195.9010505@tuffmail.co.uk>
References: <49201401.1060600@tuffmail.co.uk>	<4921E574.3090602@tuffmail.co.uk> <20081117181336.1a270561@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, atl1-devel@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:2486 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbYKROav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 09:30:51 -0500
Received: by ey-out-2122.google.com with SMTP id 6so1173062eyi.37
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 06:30:49 -0800 (PST)
In-Reply-To: <20081117181336.1a270561@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> [adding netdev to cc list]
>
> On Mon, 17 Nov 2008 21:43:16 +0000
> Alan Jenkins <alan-jenkins@tuffmail.co.uk> wrote:
>
>
>   
>> Don't listen to me.  The problem went away because when I was testing
>> my patch, I plugged the ethernet in and actually used it.  My patch
>> doesn't seem to fix anything.
>>
>> So I now have the steps to reproduce this warning: remove the ethernet
>> cable and suspend.
>>
>> Also, I was speaking rubbish because the warning isn't on the resume
>> path.  It seems to be when network-manager re-opens the device on
>> resume.
>>
>> I'll have another look for possible culprits.  Hints appreciated :).
>>     
>
> Does this help?
>   

Ah! Yes, that fixes it, thanks.

> diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
> index f5bdc92..5b292f0 100644
> --- a/drivers/net/atlx/atl2.c
> +++ b/drivers/net/atlx/atl2.c
> @@ -1690,10 +1690,6 @@ static int atl2_resume(struct pci_dev *pdev)
>  
>  	ATL2_WRITE_REG(&adapter->hw, REG_WOL_CTRL, 0);
>  
> -	err = atl2_request_irq(adapter);
> -	if (netif_running(netdev) && err)
> -		return err;
> -
> 	atl2_reset_hw(&adapter->hw);
>  
> 	if (netif_running(netdev))
>   

