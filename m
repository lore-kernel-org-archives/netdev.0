From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] TI DaVinci EMAC: Minor macro related updates
Date: Thu, 01 Oct 2009 16:11:13 +0400
Message-ID: <4AC49C61.3060501@ru.mvista.com>
References: <1254428719-13960-1-git-send-email-chaithrika@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, davem@davemloft.net
To: Chaithrika U S <chaithrika@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:24360 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756525AbZJAMIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 08:08:23 -0400
In-Reply-To: <1254428719-13960-1-git-send-email-chaithrika@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Chaithrika U S wrote:

> Use BIT for macro definitions wherever possible, remove
> unused and redundant macros.
> 
> Signed-off-by: Chaithrika U S <chaithrika@ti.com>
[...]
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 65a2d0b..a421ec0 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -164,16 +164,14 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
>  # define EMAC_MBP_MCASTCHAN(ch)		((ch) & 0x7)
>  
>  /* EMAC mac_control register */
> -#define EMAC_MACCONTROL_TXPTYPE		(0x200)
> -#define EMAC_MACCONTROL_TXPACEEN	(0x40)
> -#define EMAC_MACCONTROL_MIIEN		(0x20)
> -#define EMAC_MACCONTROL_GIGABITEN	(0x80)
> -#define EMAC_MACCONTROL_GIGABITEN_SHIFT (7)
> -#define EMAC_MACCONTROL_FULLDUPLEXEN	(0x1)
> +#define EMAC_MACCONTROL_TXPTYPE		BIT(9)
> +#define EMAC_MACCONTROL_TXPACEEN	BIT(6)
> +#define EMAC_MACCONTROL_GMIIEN		BIT(5)
> +#define EMAC_MACCONTROL_GIGABITEN	BIT(7)
> +#define EMAC_MACCONTROL_FULLDUPLEXEN	BIT(0)
>  #define EMAC_MACCONTROL_RMIISPEED_MASK	BIT(15)

    Can we have these properly sorted by value, while you're at it?

>  
>  /* GIGABIT MODE related bits */
> -#define EMAC_DM646X_MACCONTORL_GMIIEN	BIT(5)
>  #define EMAC_DM646X_MACCONTORL_GIG	BIT(7)
>  #define EMAC_DM646X_MACCONTORL_GIGFORCE	BIT(17)
>  
> @@ -192,10 +190,10 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
>  #define EMAC_RX_BUFFER_OFFSET_MASK	(0xFFFF)
>  
>  /* MAC_IN_VECTOR (0x180) register bit fields */
> -#define EMAC_DM644X_MAC_IN_VECTOR_HOST_INT	      (0x20000)
> -#define EMAC_DM644X_MAC_IN_VECTOR_STATPEND_INT	      (0x10000)
> -#define EMAC_DM644X_MAC_IN_VECTOR_RX_INT_VEC	      (0x0100)
> -#define EMAC_DM644X_MAC_IN_VECTOR_TX_INT_VEC	      (0x01)
> +#define EMAC_DM644X_MAC_IN_VECTOR_HOST_INT	BIT(17)
> +#define EMAC_DM644X_MAC_IN_VECTOR_STATPEND_INT	BIT(16)
> +#define EMAC_DM644X_MAC_IN_VECTOR_RX_INT_VEC	BIT(8)
> +#define EMAC_DM644X_MAC_IN_VECTOR_TX_INT_VEC	BIT(0)
>  
>  /** NOTE:: For DM646x the IN_VECTOR has changed */
>  #define EMAC_DM646X_MAC_IN_VECTOR_RX_INT_VEC	BIT(EMAC_DEF_RX_CH)
> @@ -203,7 +201,6 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
>  #define EMAC_DM646X_MAC_IN_VECTOR_HOST_INT	BIT(26)
>  #define EMAC_DM646X_MAC_IN_VECTOR_STATPEND_INT	BIT(27)
>  
> -
>  /* CPPI bit positions */
>  #define EMAC_CPPI_SOP_BIT		BIT(31)
>  #define EMAC_CPPI_EOP_BIT		BIT(30)
> @@ -747,8 +744,7 @@ static void emac_update_phystatus(struct emac_priv *priv)
>  
>  	if (priv->speed == SPEED_1000 && (priv->version == EMAC_VERSION_2)) {
>  		mac_control = emac_read(EMAC_MACCONTROL);
> -		mac_control |= (EMAC_DM646X_MACCONTORL_GMIIEN |
> -				EMAC_DM646X_MACCONTORL_GIG |
> +		mac_control |= (EMAC_DM646X_MACCONTORL_GIG |
>  				EMAC_DM646X_MACCONTORL_GIGFORCE);
>  	} else {
>  		/* Clear the GIG bit and GIGFORCE bit */
> @@ -2105,7 +2101,7 @@ static int emac_hw_enable(struct emac_priv *priv)
>  
>  	/* Enable MII */
>  	val = emac_read(EMAC_MACCONTROL);
> -	val |= (EMAC_MACCONTROL_MIIEN);
> +	val |= (EMAC_MACCONTROL_GMIIEN);

    Parens not needed.

>  	emac_write(EMAC_MACCONTROL, val);
>  
>  	/* Enable NAPI and interrupts */

WBR, Sergei
