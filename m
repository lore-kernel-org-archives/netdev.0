From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next  10/18] liquidio support for new device cn23xx
Date: Thu, 4 Aug 2016 17:07:34 +0000
Message-ID: <CO2PR11MB0088F3E8187DAC13B3FED31E97070@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1470250549-10993-11-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0092.outbound.protection.outlook.com ([104.47.38.92]:59552
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758865AbcHDRkg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 13:40:36 -0400
In-Reply-To: <1470250549-10993-11-git-send-email-rvatsavayi@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	/** Complete DPI init is done at firmware level. */
> +	/*cn23xx_set_dpi_regs(oct);*/
Should be removed?

> +int cn23xx_fw_lock(struct octeon_device *oct)
> +{
> +	dev_dbg(&oct->pci_dev->dev, "%s : PF = %d\n", __func__, oct-
> >pf_num);
> +	return 0;
> +}
> +
> +int cn23xx_fw_unlock(struct octeon_device *oct)
> +{
> +	dev_dbg(&oct->pci_dev->dev, "%s : PF = %d\n", __func__, oct-
> >pf_num);
> +	return 0;
> +}
A bit odd that you have lock/unlock functions that only print.
Are you later extending them?

> +		if (!(OCTEON_CN23XX_PF(oct)) ||
> +		    (OCTEON_CN23XX_PF(oct) && (oct->octeon_id == 0)))
Can simply be
		If (!(OCTEON_CN23XX_PF(oct) || !oct->octeon_id)

> +		if (!cn23xx_fw_loaded(octeon_dev)) {
> +			fw_loaded = 0;
> +			/* Do a soft reset of the Octeon device. */
I can never remember - are empty lines prior to comments
nice-to-have or a style requirement?

> +			}
> +			/*Lock again soft reset equivalent to unlock */
Likewise

> +	if ((!OCTEON_CN23XX_PF(octeon_dev)) ||
> +	    (OCTEON_CN23XX_PF(octeon_dev) && !fw_loaded)) {
	If (!A || (A && !B)) == (!A || !B)

> +		if (ddr_timeout == 0) {
	If (!ddr_timeout)

> +		while (ddr_timeout == 0) {
Likewise

> +		if (octeon_wait_for_bootloader(octeon_dev, 1000) != 0) {
No need for `!= 0`
