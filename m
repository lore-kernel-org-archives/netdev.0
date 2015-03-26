From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 5/8] NFC: NCI: Don't call setup if previous NCI request
 failed
Date: Thu, 26 Mar 2015 01:29:56 +0100
Message-ID: <20150326002956.GD10954@ribalta.home>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-6-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Robert Dolca <robert.dolca@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424772112-27399-6-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Robert,

On Tue, Feb 24, 2015 at 12:01:49PM +0200, Robert Dolca wrote:
> If the previous nci_request (NCI reset) failed the setup function
> was being called anyway. It shouldn't be called if the reset failed.
> 
> The result of the setup function is taken into consideration. If it
> fails the init should fail.
> 
> Signed-off-by: Robert Dolca <robert.dolca@intel.com>
> ---
>  net/nfc/nci/core.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
> index 1a449ac..d2e7adf 100644
> --- a/net/nfc/nci/core.c
> +++ b/net/nfc/nci/core.c
> @@ -365,8 +365,8 @@ static int nci_open_device(struct nci_dev *ndev)
>  	rc = __nci_request(ndev, nci_reset_req, 0,
>  			   msecs_to_jiffies(NCI_RESET_TIMEOUT));
>  
> -	if (ndev->ops->setup)
> -		ndev->ops->setup(ndev);
> +	if (!rc && ndev->ops->setup)
> +		rc = ndev->ops->setup(ndev);
That one makes sense.

Cheers,
Samuel.
