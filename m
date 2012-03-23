From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 09/10] stmmac: MDC clock dynamically based on the csr clock input
Date: Fri, 23 Mar 2012 09:53:02 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EB8@saturn3.aculab.com>
References: <1332493721-28309-10-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <srinivas.kandagatla@st.com>,
	<deepak.sikri@st.com>, <spear-devel@list.st.com>,
	<shiraz.hashim@st.com>, <viresh.kumar@st.com>,
	<bhutchings@solarflare.com>
To: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41830 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752022Ab2CWJyN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 05:54:13 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20803-10 for <netdev@vger.kernel.org>;
 Fri, 23 Mar 2012 09:54:09 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1332493721-28309-10-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Giuseppe CAVALLARO
> Sent: 23 March 2012 09:09
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; srinivas.kandagatla@st.com; 
> deepak.sikri@st.com; spear-devel@list.st.com; 
> shiraz.hashim@st.com; viresh.kumar@st.com; 
> bhutchings@solarflare.com; Giuseppe Cavallaro
> Subject: [PATCH 09/10] stmmac: MDC clock dynamically based on 
> the csr clock input
> 
> If a specific clk_csr value is passed from the platform
> this means that the CSR Clock Range selection cannot be
> changed at run-time and it is fixed (as reported in the driver
> documentation). Viceversa the driver will try to set the MDC
> clock dynamically according to the actual clock input.
> 
> Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
> Reviewed-by: Francesco Virlinzi <francesco.virlinzi@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  Documentation/networking/stmmac.txt               |    2 +-
>  drivers/net/ethernet/stmicro/stmmac/common.h      |   10 +++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   40 
> +++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    4 +-
>  5 files changed, 54 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/networking/stmmac.txt 
> b/Documentation/networking/stmmac.txt
> index eacb640..ab1e8d7 100644
> --- a/Documentation/networking/stmmac.txt
> +++ b/Documentation/networking/stmmac.txt
> @@ -137,7 +137,7 @@ Where:
>   o pbl: the Programmable Burst Length is maximum number of beats to
>         be transferred in one DMA transaction.
>         GMAC also enables the 4xPBL by default.
> - o clk_csr: CSR Clock range selection.
> + o clk_csr: fixed CSR Clock range selection.
>   o has_gmac: uses the GMAC core.
>   o enh_desc: if sets the MAC will use the enhanced 
> descriptor structure.
>   o tx_coe: core is able to perform the tx csum in HW.
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h 
> b/drivers/net/ethernet/stmicro/stmmac/common.h
> index f4df1eb..312e3f1 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -97,6 +97,16 @@ struct stmmac_extra_stats {
>  	unsigned long normal_irq_n;
>  };
>  
> +/* CSR Frequency Access Defines*/
> +#define CSR_F_35M	35000000
> +#define CSR_F_60M	60000000
> +#define CSR_F_100M	100000000
> +#define CSR_F_150M	150000000
> +#define CSR_F_250M	50000000
> +#define CSR_F_300M	300000000

The value of CSR_F_250M looks like a typo.
These defines look rather pointless to me though!

Another patch has:
> -----------------------------------------
> 	Selection	MDC Clock
> -----------------------------------------
>	1000 		clk_csr_i/4
>	1001 		clk_csr_i/6
>	1010 		clk_csr_i/8
>	1011 		clk_csr_i/10
>	1100 		clk_csr_i/12
>	1101	 	clk_csr_i/14
>	1110 		clk_csr_i/16
>	1111 		clk_csr_i/18
I detect a pattern ...

	David
