From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH stable v1 04/13] net: ethernet: aquantia: Low-level
 hardware interfaces
Date: Sun, 29 Jan 2017 15:07:47 +0100
Message-ID: <ae72bc65-addf-cfbc-e9db-9d2647cd4c43@gmx.de>
References: <cover.1485665881.git.vomlehn@texas.net>
 <7a772abbea0b9e720b7afe6360f1bef6243a00c9.1485665881.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        "Pavel . Belous" <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:53490 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751229AbdA2OIL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 09:08:11 -0500
In-Reply-To: <7a772abbea0b9e720b7afe6360f1bef6243a00c9.1485665881.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2017 06:09, Alexander Loktionov wrote:

> +void itr_irq_map_en_rx_set(struct aq_hw_s *aq_hw, u32 irq_map_en_rx, u32 rx)
> +{
> +/* register address for bitfield imr_rx{r}_en */
> +	static u32 itr_imr_rxren_adr[32] = {
> +			0x00002100U, 0x00002100U, 0x00002104U, 0x00002104U,
> +			0x00002108U, 0x00002108U, 0x0000210cU, 0x0000210cU,
> +			0x00002110U, 0x00002110U, 0x00002114U, 0x00002114U,
> +			0x00002118U, 0x00002118U, 0x0000211cU, 0x0000211cU,
> +			0x00002120U, 0x00002120U, 0x00002124U, 0x00002124U,
> +			0x00002128U, 0x00002128U, 0x0000212cU, 0x0000212cU,
> +			0x00002130U, 0x00002130U, 0x00002134U, 0x00002134U,
> +			0x00002138U, 0x00002138U, 0x0000213cU, 0x0000213cU
> +		};
> +
> +/* bitmask for bitfield imr_rx{r}_en */
> +	static u32 itr_imr_rxren_msk[32] = {
> +			0x00008000U, 0x00000080U, 0x00008000U, 0x00000080U,
> +			0x00008000U, 0x00000080U, 0x00008000U, 0x00000080U,
> +			0x00008000U, 0x00000080U, 0x00008000U, 0x00000080U,
> +			0x00008000U, 0x00000080U, 0x00008000U, 0x00000080U,
> +			0x00008000U, 0x00000080U, 0x00008000U, 0x00000080U,
> +			0x00008000U, 0x00000080U, 0x00008000U, 0x00000080U,
> +			0x00008000U, 0x00000080U, 0x00008000U, 0x00000080U,
> +			0x00008000U, 0x00000080U, 0x00008000U, 0x00000080U
> +		};
> +
> +/* lower bit position of bitfield imr_rx{r}_en */
> +	static u32 itr_imr_rxren_shift[32] = {
> +			15U, 7U, 15U, 7U, 15U, 7U, 15U, 7U,
> +			15U, 7U, 15U, 7U, 15U, 7U, 15U, 7U,
> +			15U, 7U, 15U, 7U, 15U, 7U, 15U, 7U,
> +			15U, 7U, 15U, 7U, 15U, 7U, 15U, 7U
> +		};
> +
> +	aq_hw_write_reg_bit(aq_hw, itr_imr_rxren_adr[rx],
> +			    itr_imr_rxren_msk[rx],
> +			    itr_imr_rxren_shift[rx],
> +			    irq_map_en_rx);
> +}
> +
> +void itr_irq_map_en_tx_set(struct aq_hw_s *aq_hw, u32 irq_map_en_tx, u32 tx)
> +{
> +/* register address for bitfield imr_tx{t}_en */
> +	static u32 itr_imr_txten_adr[32] = {
> +			0x00002100U, 0x00002100U, 0x00002104U, 0x00002104U,
> +			0x00002108U, 0x00002108U, 0x0000210cU, 0x0000210cU,
> +			0x00002110U, 0x00002110U, 0x00002114U, 0x00002114U,
> +			0x00002118U, 0x00002118U, 0x0000211cU, 0x0000211cU,
> +			0x00002120U, 0x00002120U, 0x00002124U, 0x00002124U,
> +			0x00002128U, 0x00002128U, 0x0000212cU, 0x0000212cU,
> +			0x00002130U, 0x00002130U, 0x00002134U, 0x00002134U,
> +			0x00002138U, 0x00002138U, 0x0000213cU, 0x0000213cU
> +		};
> +
> +/* bitmask for bitfield imr_tx{t}_en */
> +	static u32 itr_imr_txten_msk[32] = {
> +			0x80000000U, 0x00800000U, 0x80000000U, 0x00800000U,
> +			0x80000000U, 0x00800000U, 0x80000000U, 0x00800000U,
> +			0x80000000U, 0x00800000U, 0x80000000U, 0x00800000U,
> +			0x80000000U, 0x00800000U, 0x80000000U, 0x00800000U,
> +			0x80000000U, 0x00800000U, 0x80000000U, 0x00800000U,
> +			0x80000000U, 0x00800000U, 0x80000000U, 0x00800000U,
> +			0x80000000U, 0x00800000U, 0x80000000U, 0x00800000U,
> +			0x80000000U, 0x00800000U, 0x80000000U, 0x00800000U
> +		};
> +
> +/* lower bit position of bitfield imr_tx{t}_en */
> +	static u32 itr_imr_txten_shift[32] = {
> +			31U, 23U, 31U, 23U, 31U, 23U, 31U, 23U,
> +			31U, 23U, 31U, 23U, 31U, 23U, 31U, 23U,
> +			31U, 23U, 31U, 23U, 31U, 23U, 31U, 23U,
> +			31U, 23U, 31U, 23U, 31U, 23U, 31U, 23U
> +		};
> +
> +	aq_hw_write_reg_bit(aq_hw, itr_imr_txten_adr[tx],
> +			    itr_imr_txten_msk[tx],
> +			    itr_imr_txten_shift[tx],
> +			    irq_map_en_tx);
> +}
> +
> +void itr_irq_map_rx_set(struct aq_hw_s *aq_hw, u32 irq_map_rx, u32 rx)
> +{
> +/* register address for bitfield imr_rx{r}[4:0] */
> +	static u32 itr_imr_rxr_adr[32] = {
> +			0x00002100U, 0x00002100U, 0x00002104U, 0x00002104U,
> +			0x00002108U, 0x00002108U, 0x0000210cU, 0x0000210cU,
> +			0x00002110U, 0x00002110U, 0x00002114U, 0x00002114U,
> +			0x00002118U, 0x00002118U, 0x0000211cU, 0x0000211cU,
> +			0x00002120U, 0x00002120U, 0x00002124U, 0x00002124U,
> +			0x00002128U, 0x00002128U, 0x0000212cU, 0x0000212cU,
> +			0x00002130U, 0x00002130U, 0x00002134U, 0x00002134U,
> +			0x00002138U, 0x00002138U, 0x0000213cU, 0x0000213cU
> +		};
> +
> +/* bitmask for bitfield imr_rx{r}[4:0] */
> +	static u32 itr_imr_rxr_msk[32] = {
> +			0x00001f00U, 0x0000001fU, 0x00001f00U, 0x0000001fU,
> +			0x00001f00U, 0x0000001fU, 0x00001f00U, 0x0000001fU,
> +			0x00001f00U, 0x0000001fU, 0x00001f00U, 0x0000001fU,
> +			0x00001f00U, 0x0000001fU, 0x00001f00U, 0x0000001fU,
> +			0x00001f00U, 0x0000001fU, 0x00001f00U, 0x0000001fU,
> +			0x00001f00U, 0x0000001fU, 0x00001f00U, 0x0000001fU,
> +			0x00001f00U, 0x0000001fU, 0x00001f00U, 0x0000001fU,
> +			0x00001f00U, 0x0000001fU, 0x00001f00U, 0x0000001fU
> +		};
> +
> +/* lower bit position of bitfield imr_rx{r}[4:0] */
> +	static u32 itr_imr_rxr_shift[32] = {
> +			8U, 0U, 8U, 0U, 8U, 0U, 8U, 0U,
> +			8U, 0U, 8U, 0U, 8U, 0U, 8U, 0U,
> +			8U, 0U, 8U, 0U, 8U, 0U, 8U, 0U,
> +			8U, 0U, 8U, 0U, 8U, 0U, 8U, 0U
> +		};
> +
> +	aq_hw_write_reg_bit(aq_hw, itr_imr_rxr_adr[rx],
> +			    itr_imr_rxr_msk[rx],
> +			    itr_imr_rxr_shift[rx],
> +			    irq_map_rx);
> +}
> +
> +void itr_irq_map_tx_set(struct aq_hw_s *aq_hw, u32 irq_map_tx, u32 tx)
> +{
> +/* register address for bitfield imr_tx{t}[4:0] */
> +	static u32 itr_imr_txt_adr[32] = {
> +			0x00002100U, 0x00002100U, 0x00002104U, 0x00002104U,
> +			0x00002108U, 0x00002108U, 0x0000210cU, 0x0000210cU,
> +			0x00002110U, 0x00002110U, 0x00002114U, 0x00002114U,
> +			0x00002118U, 0x00002118U, 0x0000211cU, 0x0000211cU,
> +			0x00002120U, 0x00002120U, 0x00002124U, 0x00002124U,
> +			0x00002128U, 0x00002128U, 0x0000212cU, 0x0000212cU,
> +			0x00002130U, 0x00002130U, 0x00002134U, 0x00002134U,
> +			0x00002138U, 0x00002138U, 0x0000213cU, 0x0000213cU
> +		};
> +
> +/* bitmask for bitfield imr_tx{t}[4:0] */
> +	static u32 itr_imr_txt_msk[32] = {
> +			0x1f000000U, 0x001f0000U, 0x1f000000U, 0x001f0000U,
> +			0x1f000000U, 0x001f0000U, 0x1f000000U, 0x001f0000U,
> +			0x1f000000U, 0x001f0000U, 0x1f000000U, 0x001f0000U,
> +			0x1f000000U, 0x001f0000U, 0x1f000000U, 0x001f0000U,
> +			0x1f000000U, 0x001f0000U, 0x1f000000U, 0x001f0000U,
> +			0x1f000000U, 0x001f0000U, 0x1f000000U, 0x001f0000U,
> +			0x1f000000U, 0x001f0000U, 0x1f000000U, 0x001f0000U,
> +			0x1f000000U, 0x001f0000U, 0x1f000000U, 0x001f0000U
> +		};
> +
> +/* lower bit position of bitfield imr_tx{t}[4:0] */
> +	static u32 itr_imr_txt_shift[32] = {
> +			24U, 16U, 24U, 16U, 24U, 16U, 24U, 16U,
> +			24U, 16U, 24U, 16U, 24U, 16U, 24U, 16U,
> +			24U, 16U, 24U, 16U, 24U, 16U, 24U, 16U,
> +			24U, 16U, 24U, 16U, 24U, 16U, 24U, 16U
> +		};

Do you really have to create fields with mostly the same values in it? 
This can be solved programmatically, cant it? Furthermore mnemonics 
should be favored over hardcoded values.



> +{
> +/* register address for bitfield rx_tc_up{t}[2:0] */
> +	static u32 rpf_rpb_rx_tc_upt_adr[8] = {
> +			0x000054c4U, 0x000054c4U, 0x000054c4U, 0x000054c4U,
> +			0x000054c4U, 0x000054c4U, 0x000054c4U, 0x000054c4U
> +		};
> +
> +/* bitmask for bitfield rx_tc_up{t}[2:0] */
> +	static u32 rpf_rpb_rx_tc_upt_msk[8] = {
> +			0x00000007U, 0x00000070U, 0x00000700U, 0x00007000U,
> +			0x00070000U, 0x00700000U, 0x07000000U, 0x70000000U
> +		};
> +
> +/* lower bit position of bitfield rx_tc_up{t}[2:0] */
> +	static u32 rpf_rpb_rx_tc_upt_shft[8] = {
> +			0U, 4U, 8U, 12U, 16U, 20U, 24U, 28U
> +		};

Same as above.


> +{
> +/* Register address for bitfield lro{L}_des_max[1:0] */
> +	static u32 rpo_lro_ldes_max_adr[32] = {
> +			0x000055A0U, 0x000055A0U, 0x000055A0U, 0x000055A0U,
> +			0x000055A0U, 0x000055A0U, 0x000055A0U, 0x000055A0U,
> +			0x000055A4U, 0x000055A4U, 0x000055A4U, 0x000055A4U,
> +			0x000055A4U, 0x000055A4U, 0x000055A4U, 0x000055A4U,
> +			0x000055A8U, 0x000055A8U, 0x000055A8U, 0x000055A8U,
> +			0x000055A8U, 0x000055A8U, 0x000055A8U, 0x000055A8U,
> +			0x000055ACU, 0x000055ACU, 0x000055ACU, 0x000055ACU,
> +			0x000055ACU, 0x000055ACU, 0x000055ACU, 0x000055ACU
> +		};
> +
> +/* Bitmask for bitfield lro{L}_des_max[1:0] */
> +	static u32 rpo_lro_ldes_max_msk[32] = {
> +			0x00000003U, 0x00000030U, 0x00000300U, 0x00003000U,
> +			0x00030000U, 0x00300000U, 0x03000000U, 0x30000000U,
> +			0x00000003U, 0x00000030U, 0x00000300U, 0x00003000U,
> +			0x00030000U, 0x00300000U, 0x03000000U, 0x30000000U,
> +			0x00000003U, 0x00000030U, 0x00000300U, 0x00003000U,
> +			0x00030000U, 0x00300000U, 0x03000000U, 0x30000000U,
> +			0x00000003U, 0x00000030U, 0x00000300U, 0x00003000U,
> +			0x00030000U, 0x00300000U, 0x03000000U, 0x30000000U
> +		};
> +
> +/* Lower bit position of bitfield lro{L}_des_max[1:0] */
> +	static u32 rpo_lro_ldes_max_shift[32] = {
> +			0U, 4U, 8U, 12U, 16U, 20U, 24U, 28U,
> +			0U, 4U, 8U, 12U, 16U, 20U, 24U, 28U,
> +			0U, 4U, 8U, 12U, 16U, 20U, 24U, 28U,
> +			0U, 4U, 8U, 12U, 16U, 20U, 24U, 28U
> +		};
> +

Same as above.

> +#define stats_rx_dma_good_octet_counterlsw__adr 0x00006808
> +/* register address for bitfield rx dma good packet counter lsw [1f:0] */
> +#define stats_rx_dma_good_pkt_counterlsw__adr 0x00006800
> +/* register address for bitfield tx dma good octet counter lsw [1f:0] */
> +#define stats_tx_dma_good_octet_counterlsw__adr 0x00008808
> +/* register address for bitfield tx dma good packet counter lsw [1f:0] */
> +#define stats_tx_dma_good_pkt_counterlsw__adr 0x00008800


For the above and all other macro definitions:
macro names should be capitalized (see Linux Coding Style).


Regards,
Lino
