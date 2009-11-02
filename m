From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] cnic: ensure ulp_type is not negative
Date: Mon, 2 Nov 2009 09:56:59 -0800
Message-ID: <1257184619.31958.3.camel@HP1>
References: <4AEF0E98.5050304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net
To: "Roel Kluin" <roel.kluin@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756327AbZKBSGf@vger.kernel.org>
In-Reply-To: <4AEF0E98.5050304@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2009-11-02 at 08:53 -0800, Roel Kluin wrote:
> `ulp_type' is signed, make sure it is not negative
> when we read the array element.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Looks good to me.  Thanks.
Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/cnic.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> index 3bf1b04..f384b0a 100644
> --- a/drivers/net/cnic.c
> +++ b/drivers/net/cnic.c
> @@ -347,7 +347,7 @@ int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
>  {
>  	struct cnic_dev *dev;
>  
> -	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> +	if (ulp_type < 0 || ulp_type >= MAX_CNIC_ULP_TYPE) {
>  		printk(KERN_ERR PFX "cnic_register_driver: Bad type %d\n",
>  		       ulp_type);
>  		return -EINVAL;
> @@ -393,7 +393,7 @@ int cnic_unregister_driver(int ulp_type)
>  	struct cnic_ulp_ops *ulp_ops;
>  	int i = 0;
>  
> -	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> +	if (ulp_type < 0 || ulp_type >= MAX_CNIC_ULP_TYPE) {
>  		printk(KERN_ERR PFX "cnic_unregister_driver: Bad type %d\n",
>  		       ulp_type);
>  		return -EINVAL;
> @@ -449,7 +449,7 @@ static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
>  	struct cnic_local *cp = dev->cnic_priv;
>  	struct cnic_ulp_ops *ulp_ops;
>  
> -	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> +	if (ulp_type < 0 || ulp_type >= MAX_CNIC_ULP_TYPE) {
>  		printk(KERN_ERR PFX "cnic_register_device: Bad type %d\n",
>  		       ulp_type);
>  		return -EINVAL;
> @@ -490,7 +490,7 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
>  	struct cnic_local *cp = dev->cnic_priv;
>  	int i = 0;
>  
> -	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> +	if (ulp_type < 0 || ulp_type >= MAX_CNIC_ULP_TYPE) {
>  		printk(KERN_ERR PFX "cnic_unregister_device: Bad type %d\n",
>  		       ulp_type);
>  		return -EINVAL;
> 
