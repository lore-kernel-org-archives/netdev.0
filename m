From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/6] stmmac: Define MDC clock selection macros.
Date: Mon, 05 Mar 2012 15:34:40 +0100
Message-ID: <4F54CF00.6030005@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: spear-devel@list.st.com, netdev@vger.kernel.org
To: Deepak SIKRI <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:42046 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932312Ab2CEOfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 09:35:17 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8BA36377
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2012 14:35:15 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 295D52491
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2012 14:35:15 +0000 (GMT)
In-Reply-To: <1330692928-30330-3-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Deepak

On 3/2/2012 1:55 PM, Deepak SIKRI wrote:
> The patch adds the macros to be used for MDC clock selection. The MDC clock
> frequency is based on scaled system clock, and has to be confined to a range
> of 1-2.5 MHz. Based on the input CSR clock, the scaling factor has to be
> selected.
> The platform specific code will provide the default value of this scaling
> factor, based on the input CSR clock.
> 
> Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
> ---
>  include/linux/stmmac.h |   23 +++++++++++++++++++++++
>  1 files changed, 23 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index aa0d99e..7332ed8 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -40,6 +40,29 @@
>  #define STMMAC_CSUM_T1	1
>  #define STMMAC_CSUM_T2	2
>  
> +/*
> + * Define the macros for CSR clock range parameters to be passed by
> + * platform code.
> + * This could also be configured at run time using CPU freq framework.
> + */
> +
> +/* CSR Frequency Access Defines*/
> +#define CSR_F_20M	20000000
> +#define CSR_F_35M	35000000
> +#define CSR_F_60M	60000000
> +#define CSR_F_100M	100000000
> +#define CSR_F_150M	150000000
> +#define CSR_F_250M	50000000
> +#define CSR_F_300M	300000000


I have some concerns about this patch.

We want to have some defines to help on setting the clk_csr (that is is
a clk divisor).

When you program the "CSR Clock Range" bits in the GMII Address Register
you can also set the bit 5 (not supported in older devices e.g. 3.41a).
In this case, the defines below do not cover all the cases, I mean:

1000 clk_csr_i/4
1001 clk_csr_i/6
1010 clk_csr_i/8
1011 clk_csr_i/10
1100 clk_csr_i/12
1101 clk_csr_i/14
1110 clk_csr_i/16
1111 clk_csr_i/18

> +/* MDC Clock Selection define*/
> +#define	STMMAC_CLK_RANGE_60_100M	0	/* MDC = Clk/42 */
> +#define	STMMAC_CLK_RANGE_100_150M	1	/* MDC = Clk/62 */
> +#define	STMMAC_CLK_RANGE_20_35M		2	/* MDC = Clk/16 */
> +#define	STMMAC_CLK_RANGE_35_60M		3	/* MDC = Clk/26 */
> +#define	STMMAC_CLK_RANGE_150_250M	4	/* MDC = Clk/102 */
> +#define	STMMAC_CLK_RANGE_250_300M	5	/* MDC = Clk/122 */

I suggest you to rename these macros as:

#define STMMAC_CSR_60_100M	0	/* MDC = Clk/42 */
...

Also, macros CSR_F_20M should be totally removed.

Peppe

> +
>  /* Platfrom data for platform device structure's platform_data field */
>  
>  struct stmmac_mdio_bus_data {
