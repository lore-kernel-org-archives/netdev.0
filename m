From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: lan9303: Move tag setup to new lan9303_setup_tagging
Date: Thu, 21 Sep 2017 10:40:38 -0400
Message-ID: <87h8vwqfmh.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170921094139.4250-1-privat@egil-hjelmeland.no> <20170921094139.4250-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921094139.4250-2-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Prepare for next patch:
> Move tag setup from lan9303_separate_ports() to new function
> lan9303_setup_tagging()
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Minor styling issues, otherwise LGTM:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

> +/* forward special tagged packets from port 0 to port 1 *or* port 2 */
> +static int lan9303_setup_tagging(struct lan9303 *chip)
> +{
> +	int ret;
> +	/* enable defining the destination port via special VLAN tagging
> +	 * for port 0
> +	 */
> +	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_INGRESS_PORT_TYPE,
> +				       LAN9303_SWE_INGRESS_PORT_TYPE_VLAN);
> +	if (ret)
> +		return ret;
> +
> +	/* tag incoming packets at port 1 and 2 on their way to port 0 to be
> +	 * able to discover their source port
> +	 */
> +	return lan9303_write_switch_reg(
> +		chip, LAN9303_BM_EGRSS_PORT_TYPE,
> +		LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0);

Please avoid this kind of alignment as much as possible.

    u32 val = LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0;

would do the trick for the +80 chars issue.

BTW, it'd be great to see sometime soon a cleanup patch which makes use
of such temporary u32 val variable for most of the
lan9303_write_switch_reg and lan9303_write_switch_port calls. ;-)


Thanks,

        Vivien
