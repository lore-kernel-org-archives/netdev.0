From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 0746/1285] Replace numeric parameter like 0444 with
 macro
Date: Tue, 2 Aug 2016 14:32:03 +0200
Message-ID: <20160802143203.0dfdbb6e@griffin>
References: <20160802114214.31794-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jesse@kernel.org, linville@tuxdriver.com,
	pshelar@nicira.com, daniel@iogearbox.net,
	hannes@stressinduktion.org, tom@herbertland.com,
	aduyck@mirantis.com, chuansheng.liu@intel.com
To: Baole Ni <baolex.ni@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40852 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934824AbcHBMdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:33:01 -0400
In-Reply-To: <20160802114214.31794-1-baolex.ni@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  2 Aug 2016 19:42:14 +0800, Baole Ni wrote:
> I find that the developers often just specified the numeric value
> when calling a macro which is defined with a parameter for access permission.
> As we know, these numeric value for access permission have had the corresponding macro,
> and that using macro can improve the robustness and readability of the code,
> thus, I suggest replacing the numeric parameter with the macro.
> 
> Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
> Signed-off-by: Baole Ni <baolex.ni@intel.com>
> ---
>  drivers/net/geneve.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index cadefe4..2ddaa09 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -32,7 +32,7 @@
>  #define VNI_HASH_SIZE		(1<<VNI_HASH_BITS)
>  
>  static bool log_ecn_error = true;
> -module_param(log_ecn_error, bool, 0644);
> +module_param(log_ecn_error, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);

0644 is much more readable than the S_IGRL macros ("Incomprehensible
Group of Random Letters"). Most people use the octal value with chmod
and umask all the time while nobody is using the macros from the shell.
As a consequence, a quick glance at the number is enough to see what the
access rights are, while the macros need to be read carefully to
understand what's going on.

I very much dislike this patchset. It makes readability worse, not
better, and increases the likelihood of errors.

 Jiri
