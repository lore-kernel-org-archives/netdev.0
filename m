From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v8 10/22] IB/hns: Add process flow to init RoCE engine
Date: Wed, 25 May 2016 21:21:02 +0300
Message-ID: <20160525182102.GO25500@leon.nu>
References: <1464188725-42805-1-git-send-email-oulijun@huawei.com>
 <1464188725-42805-11-git-send-email-oulijun@huawei.com>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tqN4RWvJTb9VNux/"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1464188725-42805-11-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--tqN4RWvJTb9VNux/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 25, 2016 at 11:05:13PM +0800, Lijun Ou wrote:
> This patch mainly initialized the RoCE engine. It is absolutely
> necessary to run RoCE. It mainly includes that configure DMAE
> user, initialize doorbell and raq operations, enable port.
>=20
> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/infiniband/hw/hns/hns_roce_common.h | 107 +++++++
>  drivers/infiniband/hw/hns/hns_roce_device.h |  15 +
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 477 ++++++++++++++++++++++=
++++++
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |  68 +++-
>  drivers/infiniband/hw/hns/hns_roce_main.c   |  20 ++
>  5 files changed, 686 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infini=
band/hw/hns/hns_roce_common.h
> index 5998778..73c6220 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_common.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_common.h
> @@ -53,6 +53,93 @@
>  #define roce_set_bit(origin, shift, val) \
>  	roce_set_field((origin), (1ul << (shift)), (shift), (val))
> =20
> +#define ROCEE_GLB_CFG_ROCEE_DB_SQ_MODE_S 3
> +#define ROCEE_GLB_CFG_ROCEE_DB_OTH_MODE_S 4
> +
> +#define ROCEE_GLB_CFG_SQ_EXT_DB_MODE_S 5
> +
> +#define ROCEE_GLB_CFG_OTH_EXT_DB_MODE_S 6
> +
> +#define ROCEE_GLB_CFG_ROCEE_PORT_ST_S 10
> +#define ROCEE_GLB_CFG_ROCEE_PORT_ST_M  \
> +	(((1UL << 6) - 1) << ROCEE_GLB_CFG_ROCEE_PORT_ST_S)
> +
> +#define ROCEE_GLB_CFG_TRP_RAQ_DROP_EN_S 16
> +
> +#define ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S 0
> +#define ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_M  \
> +	(((1UL << 24) - 1) << ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S)
> +
> +#define ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S 24
> +#define ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_M  \
> +	(((1UL << 4) - 1) << ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S)
> +
> +#define ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S 0
> +#define ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_M   \
> +	(((1UL << 24) - 1) << ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S)
> +
> +#define ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S 24
> +#define ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_M   \
> +	(((1UL << 4) - 1) << ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S)
> +
> +#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S 0
> +#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_M   \
> +	(((1UL << 16) - 1) << ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S)
> +
> +#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S 16
> +#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_M   \
> +	(((1UL << 16) - 1) << ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S)
> +
> +#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S 0
> +#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_M   \
> +	(((1UL << 16) - 1) << ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S)
> +
> +#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S 16
> +#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_M   \
> +	(((1UL << 16) - 1) << ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S)
> +
> +#define ROCEE_RAQ_WL_ROCEE_RAQ_WL_S 0
> +#define ROCEE_RAQ_WL_ROCEE_RAQ_WL_M   \
> +	(((1UL << 8) - 1) << ROCEE_RAQ_WL_ROCEE_RAQ_WL_S)
> +
> +#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S 0
> +#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_M   \
> +	(((1UL << 15) - 1) << \
> +	ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S)
> +
> +#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S 16
> +#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_M   \
> +	(((1UL << 4) - 1) << \
> +	ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S)
> +
> +#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_EN_S 20
> +
> +#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_EXT_RAQ_MODE 21
> +
> +#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S 0
> +#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_M   \
> +	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S)
> +
> +#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S 5
> +#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_M   \
> +	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S)
> +
> +#define ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S 0
> +#define ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_M   \
> +	(((1UL << 5) - 1) << ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S)
> +
> +#define ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S 5
> +#define ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_M   \
> +	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S)
> +
> +#define ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S 0
> +#define ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_M   \
> +	(((1UL << 5) - 1) << ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S)
> +
> +#define ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S 8
> +#define ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_M   \
> +	(((1UL << 5) - 1) << ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S)
> +
>  #define ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S 0
>  #define ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M   \
>  	(((1UL << 19) - 1) << ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S)
> @@ -120,6 +207,26 @@
>  #define ROCEE_ECC_CERR_ALM2_REG			0xB48
> =20
>  #define ROCEE_ACK_DELAY_REG			0x14
> +#define ROCEE_GLB_CFG_REG			0x18
> +
> +#define ROCEE_DMAE_USER_CFG1_REG		0x40
> +#define ROCEE_DMAE_USER_CFG2_REG		0x44
> +
> +#define ROCEE_DB_SQ_WL_REG			0x154
> +#define ROCEE_DB_OTHERS_WL_REG			0x158
> +#define ROCEE_RAQ_WL_REG			0x15C
> +#define ROCEE_WRMS_POL_TIME_INTERVAL_REG	0x160
> +#define ROCEE_EXT_DB_SQ_REG			0x164
> +#define ROCEE_EXT_DB_SQ_H_REG			0x168
> +#define ROCEE_EXT_DB_OTH_REG			0x16C
> +
> +#define ROCEE_EXT_DB_OTH_H_REG			0x170
> +#define ROCEE_EXT_DB_SQ_WL_EMPTY_REG		0x174
> +#define ROCEE_EXT_DB_SQ_WL_REG			0x178
> +#define ROCEE_EXT_DB_OTHERS_WL_EMPTY_REG	0x17C
> +#define ROCEE_EXT_DB_OTHERS_WL_REG		0x180
> +#define ROCEE_EXT_RAQ_REG			0x184
> +#define ROCEE_EXT_RAQ_H_REG			0x188
> =20
>  #define ROCEE_CAEP_CE_INTERVAL_CFG_REG		0x190
>  #define ROCEE_CAEP_CE_BURST_NUM_CFG_REG		0x194
> diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infini=
band/hw/hns/hns_roce_device.h
> index 46f5d9f..fa906c1 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_device.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h
> @@ -64,6 +64,8 @@
>  /* Address shift 44bit with the special hardware address operation of Ro=
CEE */
>  #define ADDR_SHIFT_44				44
> =20
> +#define PAGES_SHIFT_16				16
> +
>  enum hns_roce_event {
>  	HNS_ROCE_EVENT_TYPE_PATH_MIG                  =3D 0x01,
>  	HNS_ROCE_EVENT_TYPE_PATH_MIG_FAILED           =3D 0x02,
> @@ -120,6 +122,9 @@ enum {
>  	HNS_ROCE_CMD_SUCCESS			=3D 1,
>  };
> =20
> +#define HNS_ROCE_PORT_DOWN		0
> +#define HNS_ROCE_PORT_UP		1
> +
>  struct hns_roce_uar {
>  	u64		pfn;
>  	unsigned long	index;
> @@ -205,6 +210,13 @@ struct hns_roce_cq_table {
>  	struct hns_roce_icm_table	table;
>  };
> =20
> +struct hns_roce_raq_table {
> +	void __iomem			*e_raq_addr;
> +	void __iomem			*e_raq_wl_addr;
> +	void __iomem			*e_raq_shift_addr;
> +	struct hns_roce_buf_list	*e_raq_buf;
> +};
> +
>  struct hns_roce_cmd_context {
>  	struct completion	done;
>  	int			result;
> @@ -326,6 +338,9 @@ struct hns_roce_caps {
>  struct hns_roce_hw {
>  	int (*reset)(struct hns_roce_dev *hr_dev, bool enable);
>  	void (*hw_profile)(struct hns_roce_dev *hr_dev);
> +	int (*hw_init)(struct hns_roce_dev *hr_dev);
> +	void (*hw_uninit)(struct hns_roce_dev *hr_dev);

uninit -> "exit or cleanup", it is relevant to whole patch.

> +	void	*priv;
>  };
> =20
>  struct hns_roce_dev {
> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infinib=
and/hw/hns/hns_roce_hw_v1.c
> index dd92012..9cd6c1a 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> @@ -39,6 +39,431 @@
>  #include "hns_roce_device.h"
>  #include "hns_roce_hw_v1.h"
> =20
> +void hns_roce_set_db_event_mode(struct hns_roce_dev *hr_dev, int sdb_mod=
e,
> +				int odb_mode)
> +{
> +	u32 val;
> +
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +	roce_set_bit(val, ROCEE_GLB_CFG_ROCEE_DB_SQ_MODE_S, sdb_mode);
> +	roce_set_bit(val, ROCEE_GLB_CFG_ROCEE_DB_OTH_MODE_S, odb_mode);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +}
> +
> +void hns_roce_set_db_ext_mode(struct hns_roce_dev *hr_dev,
> +			      u32 sdb_mode, u32 odb_mode)
> +{
> +	u32 val;
> +
> +	/* Configure SDB/ODB extend mode */
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +	roce_set_bit(val, ROCEE_GLB_CFG_SQ_EXT_DB_MODE_S, sdb_mode);
> +	roce_set_bit(val, ROCEE_GLB_CFG_OTH_EXT_DB_MODE_S, odb_mode);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +}
> +
> +void hns_roce_set_sdb(struct hns_roce_dev *hr_dev, u32 sdb_alept, u32 sd=
b_alful)
> +{
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_db_table *db;
> +	u32 val;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	db =3D &priv->db_table;
> +
> +	db->sdb_almept =3D sdb_alept;
> +	db->sdb_almful =3D sdb_alful;
> +
> +	/* Configure SDB */
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_DB_SQ_WL_REG);
> +	roce_set_field(val, ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_M,
> +		       ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S, db->sdb_almful);
> +	roce_set_field(val, ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_M,
> +		       ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S, db->sdb_almept);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_DB_SQ_WL_REG);
> +}
> +
> +void hns_roce_set_odb(struct hns_roce_dev *hr_dev, u32 odb_alept, u32 od=
b_alful)
> +{
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_db_table *db;
> +	u32 val;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	db =3D &priv->db_table;
> +
> +	db->odb_almept =3D odb_alept;
> +	db->odb_almful =3D odb_alful;
> +
> +	/* Configure ODB */
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_DB_OTHERS_WL_REG);
> +	roce_set_field(val, ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_M,
> +		       ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S, db->odb_almful);
> +	roce_set_field(val, ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_M,
> +		       ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S,
> +		       db->odb_almept);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_DB_OTHERS_WL_REG);
> +}
> +
> +void hns_roce_set_sdb_ext(struct hns_roce_dev *hr_dev, u32 ext_sdb_alept,
> +			  u32 ext_sdb_alful)
> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_db_table *db;
> +	dma_addr_t sdb_dma_addr;
> +	u32 val;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	db =3D &priv->db_table;
> +
> +	db->ext_db->esdb_almept =3D ext_sdb_alept;
> +	db->ext_db->esdb_alful =3D ext_sdb_alful;
> +
> +	/* Configure extend SDB threshold */
> +	roce_writel(db->ext_db->esdb_almept,
> +		    hr_dev->reg_base + ROCEE_EXT_DB_SQ_WL_EMPTY_REG);
> +	roce_writel(db->ext_db->esdb_alful,
> +		    hr_dev->reg_base + ROCEE_EXT_DB_SQ_WL_REG);
> +
> +	/* Configure extend SDB base addr */
> +	sdb_dma_addr =3D db->ext_db->sdb_buf_list->map;
> +	roce_writel((u32)(sdb_dma_addr >> ADDR_SHIFT_12),
> +		     hr_dev->reg_base + ROCEE_EXT_DB_SQ_REG);
> +
> +	/* Configure extend SDB depth */
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_EXT_DB_SQ_H_REG);
> +	roce_set_field(val, ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_M,
> +		       ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S,
> +		       db->ext_db->esdb_dep);
> +	roce_set_field(val, ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_M,
> +		       ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S,
> +		       sdb_dma_addr >> ADDR_SHIFT_44);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_EXT_DB_SQ_H_REG);
> +
> +	dev_dbg(dev, "ext SDB depth: 0x%x\n", db->ext_db->esdb_dep);
> +	dev_dbg(dev, "ext SDB threshold: epmty: 0x%x, ful: 0x%x\n",
> +		db->ext_db->esdb_almept, db->ext_db->esdb_alful);
> +}
> +
> +void hns_roce_set_odb_ext(struct hns_roce_dev *hr_dev, u32 ext_odb_alept,
> +			  u32 ext_odb_alful)
> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_db_table *db;
> +	dma_addr_t odb_dma_addr;
> +	u32 val;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	db =3D &priv->db_table;
> +
> +	db->ext_db->eodb_almept =3D ext_odb_alept;
> +	db->ext_db->eodb_alful =3D ext_odb_alful;
> +
> +	/* Configure extend ODB threshold */
> +	roce_writel(db->ext_db->eodb_almept,
> +		    hr_dev->reg_base + ROCEE_EXT_DB_OTHERS_WL_EMPTY_REG);
> +	roce_writel(db->ext_db->eodb_alful,
> +		    hr_dev->reg_base + ROCEE_EXT_DB_OTHERS_WL_REG);
> +
> +	/* Configure extend ODB base addr */
> +	odb_dma_addr =3D db->ext_db->odb_buf_list->map;
> +	roce_writel((u32)(odb_dma_addr >> ADDR_SHIFT_12),
> +		     hr_dev->reg_base + ROCEE_EXT_DB_OTH_REG);
> +
> +	/* Configure extend ODB depth */
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_EXT_DB_OTH_H_REG);
> +	roce_set_field(val, ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_M,
> +		       ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S,
> +		       db->ext_db->eodb_dep);
> +	roce_set_field(val, ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_M,
> +		       ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S,
> +		       db->ext_db->eodb_dep);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_EXT_DB_OTH_H_REG);
> +
> +	dev_dbg(dev, "ext ODB depth: 0x%x\n", db->ext_db->eodb_dep);
> +	dev_dbg(dev, "ext ODB threshold: empty: 0x%x, ful: 0x%x\n",
> +		db->ext_db->eodb_almept, db->ext_db->eodb_alful);
> +}
> +
> +int hns_roce_db_ext_init(struct hns_roce_dev *hr_dev, u32 sdb_ext_mod,
> +			 u32 odb_ext_mod)
> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_db_table *db;
> +	dma_addr_t sdb_dma_addr;
> +	dma_addr_t odb_dma_addr;
> +	int ret =3D 0;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	db =3D &priv->db_table;
> +
> +	db->ext_db =3D kmalloc(sizeof(*db->ext_db), GFP_KERNEL);
> +	if (!db->ext_db) {
> +		ret =3D -ENOMEM;
> +		dev_err(dev, "extend db buf alloc fail\n");

There is no need to print error/debug messages for memory allocation
errors. Memory allocator will print it for you.


> +		return ret;
> +	}
> +
> +	if (sdb_ext_mod) {
> +		db->ext_db->sdb_buf_list =3D kmalloc(
> +				sizeof(*db->ext_db->sdb_buf_list), GFP_KERNEL);
> +		if (!db->ext_db->sdb_buf_list) {
> +			ret =3D -ENOMEM;
> +			dev_err(dev, "sdb buf alloc failed\n");

The same comment as above.
It is relevant to all patches.

> +			goto ext_sdb_buf_fail_out;
> +		}
> +
> +		db->ext_db->sdb_buf_list->buf =3D dma_alloc_coherent(dev,
> +						     HNS_ROCE_V1_EXT_SDB_SIZE,
> +						     &sdb_dma_addr, GFP_KERNEL);
> +		if (!db->ext_db->sdb_buf_list->buf) {
> +			ret =3D -ENOMEM;
> +			dev_err(dev, "Send queue db buf alloc fail\n");
> +			goto alloc_sq_db_buf_fail;
> +		}
> +		db->ext_db->sdb_buf_list->map =3D sdb_dma_addr;
> +
> +		db->ext_db->esdb_dep =3D ilog2(HNS_ROCE_V1_EXT_SDB_DEPTH);
> +		hns_roce_set_sdb_ext(hr_dev, HNS_ROCE_V1_EXT_SDB_ALEPT,
> +				     HNS_ROCE_V1_EXT_SDB_ALFUL);
> +	} else
> +		hns_roce_set_sdb(hr_dev, HNS_ROCE_V1_SDB_ALEPT,
> +				 HNS_ROCE_V1_SDB_ALFUL);
> +
> +	if (odb_ext_mod) {
> +		db->ext_db->odb_buf_list =3D kmalloc(
> +				sizeof(*db->ext_db->odb_buf_list), GFP_KERNEL);
> +		if (!db->ext_db->odb_buf_list) {
> +			ret =3D -ENOMEM;
> +			dev_err(dev, "odb buf alloc failed\n");
> +			goto ext_odb_buf_fail_out;
> +		}
> +
> +		db->ext_db->odb_buf_list->buf =3D dma_alloc_coherent(dev,
> +						     HNS_ROCE_V1_EXT_ODB_SIZE,
> +						     &odb_dma_addr, GFP_KERNEL);
> +		if (!db->ext_db->odb_buf_list->buf) {
> +			ret =3D -ENOMEM;
> +			dev_err(dev, "Other queue db buf alloc fail\n");
> +			goto alloc_otr_db_buf_fail;
> +		}
> +		db->ext_db->odb_buf_list->map =3D odb_dma_addr;
> +
> +		db->ext_db->eodb_dep =3D ilog2(HNS_ROCE_V1_EXT_ODB_DEPTH);
> +		hns_roce_set_odb_ext(hr_dev, HNS_ROCE_V1_EXT_ODB_ALEPT,
> +				     HNS_ROCE_V1_EXT_ODB_ALFUL);
> +	} else
> +		hns_roce_set_odb(hr_dev, HNS_ROCE_V1_ODB_ALEPT,
> +				 HNS_ROCE_V1_ODB_ALFUL);
> +
> +	hns_roce_set_db_ext_mode(hr_dev, sdb_ext_mod, odb_ext_mod);
> +
> +	return 0;
> +
> +alloc_otr_db_buf_fail:
> +	kfree(db->ext_db->odb_buf_list);
> +
> +ext_odb_buf_fail_out:
> +	if (sdb_ext_mod) {
> +		dma_free_coherent(dev, HNS_ROCE_V1_EXT_SDB_SIZE,
> +				  db->ext_db->sdb_buf_list->buf,
> +				  db->ext_db->sdb_buf_list->map);
> +	}
> +
> +alloc_sq_db_buf_fail:
> +	if (sdb_ext_mod)
> +		kfree(db->ext_db->sdb_buf_list);
> +
> +ext_sdb_buf_fail_out:
> +	kfree(db->ext_db);
> +	return ret;
> +}
> +
> +int hns_roce_db_init(struct hns_roce_dev *hr_dev)
> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_db_table *db;
> +	u32 sdb_ext_mod;
> +	u32 odb_ext_mod;
> +	u32 sdb_evt_mod;
> +	u32 odb_evt_mod;
> +	int ret =3D 0;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	db =3D &priv->db_table;
> +
> +	memset(db, 0, sizeof(*db));
> +
> +	/* Default DB mode */
> +	sdb_ext_mod =3D HNS_ROCE_SDB_EXTEND_MODE;
> +	odb_ext_mod =3D HNS_ROCE_ODB_EXTEND_MODE;
> +	sdb_evt_mod =3D HNS_ROCE_SDB_NORMAL_MODE;
> +	odb_evt_mod =3D HNS_ROCE_ODB_POLL_MODE;
> +
> +	db->sdb_ext_mod =3D sdb_ext_mod;
> +	db->odb_ext_mod =3D odb_ext_mod;
> +
> +	/* Init extend DB */
> +	ret =3D hns_roce_db_ext_init(hr_dev, sdb_ext_mod, odb_ext_mod);
> +	if (ret) {
> +		dev_err(dev, "Failed in extend DB configuration.\n");
> +		return ret;
> +	}
> +
> +	hns_roce_set_db_event_mode(hr_dev, sdb_evt_mod, odb_evt_mod);
> +
> +	return 0;
> +}
> +
> +void hns_roce_db_free(struct hns_roce_dev *hr_dev)
> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_db_table *db;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	db =3D &priv->db_table;
> +
> +	if (db->sdb_ext_mod) {
> +		dma_free_coherent(dev, HNS_ROCE_V1_EXT_SDB_SIZE,
> +				  db->ext_db->sdb_buf_list->buf,
> +				  db->ext_db->sdb_buf_list->map);
> +		kfree(db->ext_db->sdb_buf_list);
> +	}
> +
> +	if (db->odb_ext_mod) {
> +		dma_free_coherent(dev, HNS_ROCE_V1_EXT_ODB_SIZE,
> +				  db->ext_db->odb_buf_list->buf,
> +				  db->ext_db->odb_buf_list->map);
> +		kfree(db->ext_db->odb_buf_list);
> +	}
> +
> +	kfree(db->ext_db);
> +}
> +
> +int hns_roce_raq_init(struct hns_roce_dev *hr_dev)
> +{
> +	int ret;
> +	int raq_shift =3D 0;
> +	dma_addr_t addr;
> +	u32 val;
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_raq_table *raq;
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	raq =3D &priv->raq_table;
> +
> +	raq->e_raq_addr =3D hr_dev->reg_base + ROCEE_EXT_RAQ_REG;
> +	raq->e_raq_wl_addr =3D hr_dev->reg_base + ROCEE_RAQ_WL_REG;
> +	raq->e_raq_shift_addr =3D hr_dev->reg_base + ROCEE_EXT_RAQ_H_REG;
> +
> +	raq->e_raq_buf =3D kzalloc(sizeof(*(raq->e_raq_buf)), GFP_KERNEL);
> +	if (!raq->e_raq_buf) {
> +		ret =3D -ENOMEM;
> +		dev_err(dev, "Failed to alloc raq buf, Aborting.\n");
> +		return ret;
> +	}
> +
> +	raq->e_raq_buf->buf =3D dma_alloc_coherent(dev, HNS_ROCE_V1_RAQ_SIZE,
> +						 &addr, GFP_KERNEL);
> +	if (!raq->e_raq_buf->buf) {
> +		ret =3D -ENOMEM;
> +		dev_err(dev, "Failed to dma_alloc ext raq buf.\n");
> +		goto _err_dma_alloc_raq;
> +	}
> +	raq->e_raq_buf->map =3D addr;
> +
> +	/* Configure raq extended address. 48bit 4K align*/
> +	roce_writel(raq->e_raq_buf->map >> ADDR_SHIFT_12, raq->e_raq_addr);
> +
> +	/* Configure raq_shift */
> +	raq_shift =3D ilog2(HNS_ROCE_V1_RAQ_SIZE / HNS_ROCE_V1_RAQ_ENTRY);
> +	val =3D roce_readl(raq->e_raq_shift_addr);
> +	roce_set_field(val, ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_M,
> +		       ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S,
> +		       raq_shift);
> +	roce_set_field(val, ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_M,
> +		       ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S,
> +		       raq->e_raq_buf->map >> ADDR_SHIFT_44);
> +	roce_writel(val, raq->e_raq_shift_addr);
> +	dev_dbg(dev, "Configure raq_shift 0x%x.\n", val);
> +
> +	/* Configure raq threshold */
> +	val =3D roce_readl(raq->e_raq_wl_addr);
> +	roce_set_field(val, ROCEE_RAQ_WL_ROCEE_RAQ_WL_M,
> +		       ROCEE_RAQ_WL_ROCEE_RAQ_WL_S,
> +		       HNS_ROCE_V1_EXT_RAQ_WF);
> +	roce_writel(val, raq->e_raq_wl_addr);
> +	dev_dbg(dev, "Configure raq_wl 0x%x.\n", val);
> +
> +	/* Enable extend raq */
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_WRMS_POL_TIME_INTERVAL_REG);
> +	roce_set_field(val,
> +		       ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_M,
> +		       ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S,
> +		       POL_TIME_INTERVAL_VAL);
> +	roce_set_bit(val, ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_EXT_RAQ_MODE, 1);
> +	roce_set_field(val,
> +		       ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_M,
> +		       ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S,
> +		       2);
> +	roce_set_bit(val,
> +		     ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_EN_S, 1);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_WRMS_POL_TIME_INTERVAL_REG);
> +	dev_dbg(dev, "Configure WrmsPolTimeInterval 0x%x.\n", val);
> +
> +	/* Enable raq drop */
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +	roce_set_bit(val, ROCEE_GLB_CFG_TRP_RAQ_DROP_EN_S, 1);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +	dev_dbg(dev, "Configure GlbCfg =3D 0x%x.\n", val);
> +
> +	return 0;
> +
> +_err_dma_alloc_raq:
> +	kfree(raq->e_raq_buf);
> +	return ret;
> +}
> +
> +void hns_roce_raq_free(struct hns_roce_dev *hr_dev)
> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct hns_roce_v1_priv *priv;
> +	struct hns_roce_raq_table *raq;
> +
> +	priv =3D (struct hns_roce_v1_priv *)hr_dev->hw->priv;
> +	raq =3D &priv->raq_table;
> +
> +	dma_free_coherent(dev, HNS_ROCE_V1_RAQ_SIZE, raq->e_raq_buf->buf,
> +			  raq->e_raq_buf->map);
> +	kfree(raq->e_raq_buf);
> +}
> +
> +void hns_roce_port_enable(struct hns_roce_dev  *hr_dev, int enable_flag)
> +{
> +	u32 val;
> +
> +	if (enable_flag) {
> +		val =3D roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +		 /* Open all ports */
> +		roce_set_field(val, ROCEE_GLB_CFG_ROCEE_PORT_ST_M,
> +			       ROCEE_GLB_CFG_ROCEE_PORT_ST_S,
> +			       ALL_PORT_VAL_OPEN);
> +		roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +	} else {
> +		val =3D roce_readl(hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +		/* Close all ports */
> +		roce_set_field(val, ROCEE_GLB_CFG_ROCEE_PORT_ST_M,
> +			       ROCEE_GLB_CFG_ROCEE_PORT_ST_S, 0x0);
> +		roce_writel(val, hr_dev->reg_base + ROCEE_GLB_CFG_REG);
> +	}
> +}
> +
>  /**
>   * hns_roce_v1_reset - reset roce
>   * @hr_dev: roce device struct pointer
> @@ -144,7 +569,59 @@ void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
>  	caps->max_mtu =3D IB_MTU_2048;
>  }
> =20
> +int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
> +{
> +	int ret;
> +	u32 val;
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +
> +	/* DMAE user config */
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_DMAE_USER_CFG1_REG);
> +	roce_set_field(val, ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_M,
> +		       ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S, 0xf);
> +	roce_set_field(val, ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_M,
> +		       ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S,
> +		       1 << PAGES_SHIFT_16);
> +	roce_writel(val, hr_dev->reg_base + ROCEE_DMAE_USER_CFG1_REG);
> +
> +	val =3D roce_readl(hr_dev->reg_base + ROCEE_DMAE_USER_CFG2_REG);
> +	roce_set_field(val, ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_M,
> +		       ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S, 0xf);
> +	roce_set_field(val, ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_M,
> +		       ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S,
> +		       1 << PAGES_SHIFT_16);
> +
> +	ret =3D hns_roce_db_init(hr_dev);
> +	if (ret) {
> +		dev_err(dev, "doorbell init failed!\n");
> +		return ret;
> +	}
> +
> +	ret =3D hns_roce_raq_init(hr_dev);
> +	if (ret) {
> +		dev_err(dev, "raq init failed!\n");
> +		goto _error_failed_raq_init;

It is uncommon to set label with underscore.

> +	}
> +
> +	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_UP);
> +
> +	return 0;
> +
> +_error_failed_raq_init:
> +	hns_roce_db_free(hr_dev);
> +	return ret;
> +}
> +
> +void hns_roce_v1_uninit(struct hns_roce_dev *hr_dev)
> +{
> +	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
> +	hns_roce_raq_free(hr_dev);
> +	hns_roce_db_free(hr_dev);
> +}
> +
>  struct hns_roce_hw hns_roce_hw_v1 =3D {
>  	.reset =3D hns_roce_v1_reset,
>  	.hw_profile =3D hns_roce_v1_profile,
> +	.hw_init =3D hns_roce_v1_init,
> +	.hw_uninit =3D hns_roce_v1_uninit,
>  };
> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infinib=
and/hw/hns/hns_roce_hw_v1.h
> index 8ddcf58..f538734 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> @@ -69,7 +69,73 @@
>  #define HNS_ROCE_V1_CQE_ENTRY_SIZE		32
>  #define HNS_ROCE_V1_PAGE_SIZE_SUPPORT		0xFFFFF000
> =20

Extra white spaces,
Please clean your patches with ./scripts/cleanfile or
=2E/scripts/cleanpatch

And indentation below seems completely out of sync.

> -#define SLEEP_TIME_INTERVAL			20
> +#define HNS_ROCE_V1_EXT_RAQ_WF			8
> +#define HNS_ROCE_V1_RAQ_ENTRY			64
> +#define HNS_ROCE_V1_RAQ_DEPTH			32768
> +#define HNS_ROCE_V1_RAQ_SIZE	(HNS_ROCE_V1_RAQ_ENTRY * HNS_ROCE_V1_RAQ_DE=
PTH)
> +
> +#define HNS_ROCE_V1_SDB_DEPTH			0x400
> +#define HNS_ROCE_V1_ODB_DEPTH			0x400
> +
> +#define HNS_ROCE_V1_DB_RSVD			0x80
> +
> +#define HNS_ROCE_V1_SDB_ALEPT			HNS_ROCE_V1_DB_RSVD
> +#define HNS_ROCE_V1_SDB_ALFUL	(HNS_ROCE_V1_SDB_DEPTH - HNS_ROCE_V1_DB_RS=
VD)
> +#define HNS_ROCE_V1_ODB_ALEPT			HNS_ROCE_V1_DB_RSVD
> +#define HNS_ROCE_V1_ODB_ALFUL	(HNS_ROCE_V1_ODB_DEPTH - HNS_ROCE_V1_DB_RS=
VD)
> +
> +#define HNS_ROCE_V1_EXT_SDB_DEPTH		0x4000
> +#define HNS_ROCE_V1_EXT_ODB_DEPTH		0x4000
> +#define HNS_ROCE_V1_EXT_SDB_ENTRY		16
> +#define HNS_ROCE_V1_EXT_ODB_ENTRY		16
> +#define HNS_ROCE_V1_EXT_SDB_SIZE  \
> +	(HNS_ROCE_V1_EXT_SDB_DEPTH * HNS_ROCE_V1_EXT_SDB_ENTRY)
> +#define HNS_ROCE_V1_EXT_ODB_SIZE  \
> +	(HNS_ROCE_V1_EXT_ODB_DEPTH * HNS_ROCE_V1_EXT_ODB_ENTRY)
> +
> +#define HNS_ROCE_V1_EXT_SDB_ALEPT		HNS_ROCE_V1_DB_RSVD
> +#define HNS_ROCE_V1_EXT_SDB_ALFUL  \
> +	(HNS_ROCE_V1_EXT_SDB_DEPTH - HNS_ROCE_V1_DB_RSVD)
> +#define HNS_ROCE_V1_EXT_ODB_ALEPT		HNS_ROCE_V1_DB_RSVD
> +#define HNS_ROCE_V1_EXT_ODB_ALFUL	\
> +	(HNS_ROCE_V1_EXT_ODB_DEPTH - HNS_ROCE_V1_DB_RSVD)
> +
> +#define HNS_ROCE_ODB_POLL_MODE		0
> +
> +#define HNS_ROCE_SDB_NORMAL_MODE	0
> +#define HNS_ROCE_SDB_EXTEND_MODE	1
> +
> +#define HNS_ROCE_ODB_EXTEND_MODE	1
> +
> +#define ALL_PORT_VAL_OPEN		0x3f
> +#define POL_TIME_INTERVAL_VAL		0x80
> +#define SLEEP_TIME_INTERVAL		20
> +
> +struct hns_roce_ext_db {
> +	int esdb_almept;
> +	int esdb_alful;
> +	int eodb_almept;
> +	int eodb_alful;
> +	int esdb_dep;
> +	int eodb_dep;
> +	struct hns_roce_buf_list *sdb_buf_list;
> +	struct hns_roce_buf_list *odb_buf_list;
> +};
> +
> +struct hns_roce_db_table {
> +	int  sdb_ext_mod;
> +	int  odb_ext_mod;
> +	int  sdb_almept;
> +	int  sdb_almful;
> +	int  odb_almept;
> +	int  odb_almful;
> +	struct hns_roce_ext_db *ext_db;
> +};
> +
> +struct hns_roce_v1_priv {
> +	struct hns_roce_db_table  db_table;
> +	struct hns_roce_raq_table raq_table;
> +};
> =20
>  extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool e=
nable);
> =20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniba=
nd/hw/hns/hns_roce_main.c
> index fe487d6..589a9f7 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_main.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> @@ -202,6 +202,16 @@ err_unmap_mtt:
>  	return ret;
>  }
> =20
> +int hns_roce_engine_init(struct hns_roce_dev  *hr_dev)
> +{
> +	return hr_dev->hw->hw_init(hr_dev);
> +}
> +
> +void hns_roce_engine_uninit(struct hns_roce_dev  *hr_dev)
> +{
> +	hr_dev->hw->hw_uninit(hr_dev);
> +}
> +
>  /**
>  * hns_roce_setup_hca - setup host channel adapter
>  * @hr_dev: pointer to hns roce device
> @@ -351,6 +361,15 @@ static int hns_roce_probe(struct platform_device *pd=
ev)
>  		goto error_failed_setup_hca;
>  	}
> =20
> +	ret =3D hns_roce_engine_init(hr_dev);
> +	if (ret) {
> +		dev_err(dev, "hw_init failed!\n");
> +		goto error_failed_engine_init;
> +	}
> +
> +error_failed_engine_init:
> +	hns_roce_cleanup_bitmap(hr_dev);
> +
>  error_failed_setup_hca:
>  	hns_roce_cleanup_icm(hr_dev);
> =20
> @@ -383,6 +402,7 @@ static int hns_roce_remove(struct platform_device *pd=
ev)
>  {
>  	struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
> =20
> +	hns_roce_engine_uninit(hr_dev);
>  	hns_roce_cleanup_bitmap(hr_dev);
>  	hns_roce_cleanup_icm(hr_dev);
> =20
> --=20
> 1.9.1
>=20

--tqN4RWvJTb9VNux/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXRe0NAAoJEORje4g2clinztQP/26NyJ+i5nbNwduMVEodHmjz
2roD0EFyAS3NzHhsC81gTpLqk1GnIFdnwLvjOhm5Kza2cZwJymO4SYbRXqoZtPHS
SJDpCaOQaexQoEs+OHXFXaAH8+47rE7cMeuyVGXAnYdmVB2l4SoItjKTJYW6b7NM
oECm5zM1a8TLlfDylfJmvdnEcQjwFch8Wt48Cz17RQL0MCbnkT/G3hTwSwiGf+9a
io0w8zOwNRSmdFXAJg8bNdxv6GoELIuKKYl1P31xBLGPgys9+IfTgk8ViRiUTLBU
mBe78jnM8ItFqdhwnl3ZK6UF4Y57Da9miewe67LEnhtwFu3TH1DO3A8qId7Cf7+b
LQuUg1uJryl1XFFXiLKMBUlIun12vBhloEmOybzP8pFTZeUp/ykp7u6AYvkT+BIk
7DeqJAaxld8pfqqHxcwprU2aHyGLm8x/gqs7wAuLcAxrUTUl+z0YHOUj0h4CgZxH
HeCdMkD1u7Iqg64kxFZRPk7qLMt2nLMeIEeULSC6D+ct0PSQ95UA31zRYXd+He0n
NL1PqT4pxAVDV0tVPzBJ4uZLlghBVWadT6Sxpqh/j/9kGTD5uEAhCJpvL+fwiDUR
ixQtuj7ailmI0QfazO610XBlocpUFQNyOR3VxYMZMQncD/1DMrlfub2aVo1bc11Y
I5/z+XHe9cAzGgOcNEUq
=khIo
-----END PGP SIGNATURE-----

--tqN4RWvJTb9VNux/--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
