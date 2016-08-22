From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next V3 08/18] liquidio: CN23XX queue manipulation
Date: Mon, 22 Aug 2016 16:45:00 +0000
Message-ID: <CO2PR11MB0088059F15E0A5CEF03787A697E80@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1471824765-26473-9-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0109.outbound.protection.outlook.com ([104.47.38.109]:43232
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932367AbcHVQpE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 12:45:04 -0400
In-Reply-To: <1471824765-26473-9-git-send-email-rvatsavayi@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +		while ((READ_ONCE(reg_val) & CN23XX_PKT_INPUT_CTL_RST)
> &&
> +		       !(READ_ONCE(reg_val) & CN23XX_PKT_INPUT_CTL_QUIET))
> {
> +			WRITE_ONCE(reg_val, octeon_read_csr64(
> +			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no)));
> +		}
Busy-reading registers without any timeout. Couldn't there be corner cases =
[PCI errors, etc.]?
[This is a recurring event in this patch]

> +static void cn23xx_disable_io_queues(struct octeon_device *oct) {
> +	u64 d64 =3D 0ULL;
> +	u32 d32 =3D 0ULL;
While true, why bother with the ULLs?

> +
> +		/* Reset the doorbell register for this Input Queue. */
> +		octeon_write_csr(oct, CN23XX_SLI_IQ_DOORBELL(q_no),
> 0xFFFFFFFF);
> +		while (((octeon_read_csr64(
> +			    oct, CN23XX_SLI_IQ_DOORBELL(q_no))) !=3D 0ULL) &&
!, not !=3D 0.

> CN23XX_SLI_PKT_IOQ_RING_RST));
> +		while (!(READ_ONCE(d64) & (0x1ULL << q_no)) && loop--) {
You can use BIT_ULL for this

> +		/* Reset the doorbell register for this Output Queue. */
> +		octeon_write_csr(oct, CN23XX_SLI_OQ_PKTS_CREDIT(q_no),
> +				 0xFFFFFFFF);
> +		while (((octeon_read_csr64(
> +			    oct, CN23XX_SLI_OQ_PKTS_CREDIT(q_no))) !=3D 0ULL)
!, not !=3D 0.

=20
