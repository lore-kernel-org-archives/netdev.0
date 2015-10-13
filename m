From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 5/6] e1000 driver remove checkpatch errors, warnings and
 checks.
Date: Tue, 13 Oct 2015 15:23:42 -0700
Message-ID: <561D846E.1050405@gmail.com>
References: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
 <1444772362-25090-5-git-send-email-januszwolak@awokados.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Janusz Wolak <januszvdm@gmail.com>
To: Janusz Wolak <januszwolak@awokados.com.pl>,
	jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444772362-25090-5-git-send-email-januszwolak@awokados.com.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/13/2015 02:39 PM, Janusz Wolak wrote:
> From: Janusz Wolak <januszvdm@gmail.com>
>
> Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
> ---
>   drivers/net/ethernet/intel/e1000/e1000_param.c | 114 ++++++++++++++++++-------
>   1 file changed, 82 insertions(+), 32 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c b/drivers/net/ethernet/intel/e1000/e1000_param.c
> index c9cde35..9ec730e 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_param.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
> @@ -1,5 +1,5 @@
>   /*******************************************************************************
> -
> +*
>     Intel PRO/1000 Linux driver
>     Copyright(c) 1999 - 2006 Intel Corporation.
>   
> @@ -45,10 +45,10 @@
>   
>   #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
>   #define E1000_PARAM(X, desc) \
> -	static int X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
> +	static int X[E1000_MAX_NIC + 1] = E1000_PARAM_INIT; \
>   	static unsigned int num_##X; \
>   	module_param_array_named(X, X, int, &num_##X, 0); \
> -	MODULE_PARM_DESC(X, desc);
> +	MODULE_PARM_DESC(X, desc)
>   
>   /* Transmit Descriptor Count
>    *
> @@ -200,6 +200,7 @@ struct e1000_option {
>   		} r;
>   		struct { /* list_option info */
>   			int nr;
> +
>   			const struct e1000_opt_list { int i; char *str; } *p;
>   		} l;
>   	} arg;

How is adding a space here adding any value?  Please don't just blindly 
follow checkpatch as it can give out erroneous information.

Looking over most of this patch series it seems like it is taking 
readability in the wrong direction and reducing the ability to maintain 
the driver since this code has been "maintenance only" for some time 
now.  If somebody comes up with a legitimate fix for an issue at some 
point in the future they will need to work around these patches in order 
to back-port it into a stable release and that just hurts maintainability.

I'd say this whole series should be rejected on the grounds that this 
driver is mostly stable and should only really be modified for bug fixes 
at this point.  If we really need to go through and do a checkpatch 
sweep we should probably just focus on serious errors only instead of 
going astray and chasing down things that are false hits or minor issues 
that are mostly a matter of preference.

- Alex
