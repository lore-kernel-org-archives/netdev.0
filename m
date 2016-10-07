From: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 03/10] i2c: Juniper SAM I2C driver
Date: Fri,  7 Oct 2016 18:18:31 +0300
Message-ID: <1475853518-22264-4-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
        David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Brian Norris <computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>,
        Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>,
        Debjit Ghosh <dghosh-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Maryam Seraj <mseraj-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, li
To: Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475853518-22264-1-git-send-email-pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Maryam Seraj <mseraj-3r7Miqu9kMnR7s880joybQ@public.gmane.org>

Introduce SAM I2C driver for the I2C interfaces on the Juniper
SAM FPGA.

Signed-off-by: Maryam Seraj <mseraj-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
Signed-off-by: Debjit Ghosh <dghosh-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
Signed-off-by: Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
Signed-off-by: Guenter Roeck <groeck-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
Signed-off-by: Rajat Jain <rajatjain-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
---
 drivers/i2c/busses/Kconfig   |  11 +
 drivers/i2c/busses/Makefile  |   1 +
 drivers/i2c/busses/i2c-sam.c | 942 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 954 insertions(+)
 create mode 100644 drivers/i2c/busses/i2c-sam.c

diff --git a/drivers/i2c/busses/Kconfig b/drivers/i2c/busses/Kconfig
index 5c3993b..eeac4b2 100644
--- a/drivers/i2c/busses/Kconfig
+++ b/drivers/i2c/busses/Kconfig
@@ -833,6 +833,17 @@ config I2C_SH7760
 	  This driver can also be built as a module.  If so, the module
 	  will be called i2c-sh7760.
 
+config I2C_SAM
+	tristate "Juniper SAM FPGA I2C Controller"
+	select I2C_MUX
+	depends on MFD_JUNIPER_SAM || MFD_JUNIPER_CBC
+	help
+	  This driver supports the I2C interfaces on the Juniper SAM FPGA
+	  which is present on the relevant Juniper platforms.
+
+	  This driver can also be built as a module.  If so, the module
+	  will be called i2c-sam.
+
 config I2C_SH_MOBILE
 	tristate "SuperH Mobile I2C Controller"
 	depends on HAS_DMA
diff --git a/drivers/i2c/busses/Makefile b/drivers/i2c/busses/Makefile
index 37f2819..b99b229 100644
--- a/drivers/i2c/busses/Makefile
+++ b/drivers/i2c/busses/Makefile
@@ -79,6 +79,7 @@ obj-$(CONFIG_I2C_QUP)		+= i2c-qup.o
 obj-$(CONFIG_I2C_RIIC)		+= i2c-riic.o
 obj-$(CONFIG_I2C_RK3X)		+= i2c-rk3x.o
 obj-$(CONFIG_I2C_S3C2410)	+= i2c-s3c2410.o
+obj-$(CONFIG_I2C_SAM)		+= i2c-sam.o
 obj-$(CONFIG_I2C_SH7760)	+= i2c-sh7760.o
 obj-$(CONFIG_I2C_SH_MOBILE)	+= i2c-sh_mobile.o
 obj-$(CONFIG_I2C_SIMTEC)	+= i2c-simtec.o
diff --git a/drivers/i2c/busses/i2c-sam.c b/drivers/i2c/busses/i2c-sam.c
new file mode 100644
index 0000000..1ec930a
--- /dev/null
+++ b/drivers/i2c/busses/i2c-sam.c
@@ -0,0 +1,942 @@
+#include <linux/device.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/io.h>
+#include <linux/i2c.h>
+#include <linux/err.h>
+#include <linux/interrupt.h>
+#include <linux/i2c-mux.h>
+#include <linux/mfd/sam.h>
+#include <linux/platform_device.h>
+#include <linux/of.h>
+
+#define SAM_DEB1(dev, fmt, args...) do { \
+	if (sam_debug >= 1) \
+		dev_err(dev, fmt, ## args); \
+	} while (0)
+#define SAM_DEB2(dev, fmt, args...) do { \
+	if (sam_debug >= 2) \
+		dev_err(dev, fmt, ## args); \
+	} while (0)
+#define SAM_DEB3(dev, fmt, args...) do { \
+	if (sam_debug >= 3) \
+		dev_err(dev, fmt, ## args); } \
+	while (0)
+
+static int sam_debug;
+
+#define DRIVER_DESC			"SAM FPGA I2C Driver"
+#define DRIVER_VERSION			"0.2"
+#define DRIVER_AUTHOR			"Maryam Seraj <mseraj-3r7Miqu9kMnR7s880joybQ@public.gmane.org>"
+
+#define SAM_FPGA_MODULE_NAME		"i2c-sam"
+
+#define SAM_I2C_MUX_MAX_CHAN		8
+
+#define SAM_I2C_DEV_ADDR_MASK		0x7f
+#define SAM_I2C_TBL_ENTRY_CMDS_NUM	2
+
+#define SAM_I2C_CMD_TABLE_SZ		256
+
+#define SAM_I2C_STS_DONE		(1 << 0)
+#define SAM_I2C_STS_PRIO_DONE		(1 << 1)
+#define SAM_I2C_STS_RUNNING		(1 << 2)
+#define SAM_I2C_STS_PRIO_RUNNING	(1 << 3)
+#define SAM_I2C_STS_ERR			(1 << 4)
+#define SAM_I2C_STS_PRIO_ERR		(1 << 5)
+#define SAM_I2C_STS_RDY			(1 << 6)
+#define SAM_I2C_STS_TR_TIMEOUT		(1 << 7)
+#define SAM_I2C_STS_CMD_TIMEOUT		(1 << 8)
+#define SAM_I2C_STS_CMD_TABLE_TIMEOUT	(1 << 9)
+
+#define SAM_I2C_STS_CLEAR_MASK		(SAM_I2C_STS_DONE \
+					 | SAM_I2C_STS_PRIO_DONE \
+					 | SAM_I2C_STS_TR_TIMEOUT \
+					 | SAM_I2C_STS_CMD_TIMEOUT \
+					 | SAM_I2C_STS_CMD_TABLE_TIMEOUT \
+					 | SAM_I2C_STS_ERR \
+					 | SAM_I2C_STS_PRIO_ERR)
+#define SAM_I2C_STS_CLEAR(x)	(((x) & ~0x3fb3) | SAM_I2C_STS_CLEAR_MASK)
+
+#define SAM_I2C_STS_TIMEOUT		(SAM_I2C_STS_TR_TIMEOUT \
+					 | SAM_I2C_STS_CMD_TIMEOUT \
+					 | SAM_I2C_STS_CMD_TABLE_TIMEOUT)
+
+#define SAM_I2C_DONE(s)		((s) & (SAM_I2C_STS_DONE | SAM_I2C_STS_ERR \
+					| SAM_I2C_STS_TIMEOUT))
+
+#define SAM_I2C_CTRL_RESET		(1 << 0)
+#define SAM_I2C_CTRL_GO			(1 << 1)
+#define SAM_I2C_CTRL_PRIO_GO		(1 << 2)
+#define SAM_I2C_CTRL_ABORT		(1 << 3)
+#define SAM_I2C_CTRL_PRIO_ABORT		(1 << 4)
+
+/* Priority ctrl & status bits are offset +1 from the regular */
+#define STS_DONE(p)			BIT(0 + (p))
+#define STS_RUNNING(p)			BIT(2 + (p))
+#define STS_ERR(p)			BIT(4 + (p))
+#define CTRL_GO(p)			BIT(1 + (p))
+#define CTRL_ABORT(p)			BIT(3 + (p))
+#define STS_I2C_DONE(s, p)		((s) & (STS_DONE(p) | STS_ERR(p) \
+					 | SAM_I2C_STS_TIMEOUT))
+
+struct sam_i2c_data {
+	void __iomem *membase;
+	void __iomem *masterbase;
+	int first_master;
+	int num_master;
+	int mux_channels;
+	u32 *speed;		/* bit mask, 1 for high speed */
+	bool prio;
+	bool reverse_fill;
+	struct i2c_adapter **adap;
+	struct device *dev;
+	int irq;
+	struct sam_platform_data *pdata;
+};
+
+struct sam_i2c_adapdata {
+	void __iomem *membase;
+	void __iomem *masterbase;
+	int channel;
+	int mux_channels;
+	int mux_select;
+	u32 speed;			/* bit mask, same as above */
+	int prio;
+	bool reverse_fill;
+	struct i2c_adapter adap;
+	struct i2c_mux_core *muxc;
+	wait_queue_head_t wait;
+	u32 status;
+	u32 control;
+	bool done;
+	bool polling;
+};
+
+/**************************** i2c stuff *****************************/
+
+#define SAM_FPGA_MUX_NAME    "sam-fpga-mux"
+
+enum i2c_accel_cmd_bits_s {
+	I2C_WRITE,		/* 000 */
+	I2C_READ,		/* 001 */
+	I2C_WRITE_STOP,		/* 010 */
+	I2C_READ_STOP,		/* 011 */
+	I2C_WRITE_REPSTART,	/* 100 */
+	I2C_READ_REPSTART	/* 101 */
+};
+
+#define I2C_CMD_STOP_BIT	(1 << 1)
+#define I2C_CMD_REPSTART_BIT	(1 << 2)
+
+#define PER_MASTER_MEM		0x1000
+#define I2C_OPTIONS_BASE	0x2000
+#define MASTER_MEM_BASE		0x8000
+
+#define CMD_ADDR(s, idx)	((s)->masterbase + 0x0000 + \
+				 PER_MASTER_MEM * (s)->channel + \
+				 (idx) * sizeof(u32))
+#define RES_ADDR(s, idx)	((s)->masterbase + 0x0400 + \
+				 PER_MASTER_MEM * (s)->channel + \
+				 (idx) * sizeof(u32))
+#define CMD_PRI_ADDR(s, idx)	((s)->masterbase + 0x0800 + \
+				 PER_MASTER_MEM * (s)->channel + \
+				 (idx) * sizeof(u32))
+#define RES_PRI_ADDR(s, idx)	((s)->masterbase + 0x0c00 + \
+				 PER_MASTER_MEM * (s)->channel + \
+				 (idx) * sizeof(u32))
+#define CTRL_ADDR(s)		((s)->membase + 0x2400 + 8 * (s)->channel)
+#define STAT_ADDR(s)		((s)->membase + 0x2404 + 8 * (s)->channel)
+
+#define sam_i2c_stat_clear(adata, val)					\
+	do {								\
+		iowrite32(SAM_I2C_STS_CLEAR(val), STAT_ADDR(adata));	\
+		ioread32(STAT_ADDR(adata));				\
+	} while (0)
+
+static int sam_i2c_wait_rdy(struct i2c_adapter *adap)
+{
+	struct sam_i2c_adapdata *adata = i2c_get_adapdata(adap);
+	u32 val;
+	unsigned long timeout;
+
+	val = ioread32(STAT_ADDR(adata));
+	if ((val & SAM_I2C_STS_RDY) && !(val & STS_RUNNING(adata->prio)))
+		return 0;
+
+	if (val & STS_RUNNING(adata->prio)) {
+		iowrite32(adata->control | CTRL_ABORT(adata->prio),
+			  CTRL_ADDR(adata));
+		ioread32(CTRL_ADDR(adata));
+		udelay(10);
+		iowrite32(adata->control, CTRL_ADDR(adata));
+		ioread32(CTRL_ADDR(adata));
+		udelay(100);
+	}
+
+	timeout = jiffies + adap->timeout;
+	adata->status = 0;
+	do {
+		val = ioread32(STAT_ADDR(adata)) | adata->status;
+		if ((val & SAM_I2C_STS_RDY) &&
+		    !(val & STS_RUNNING(adata->prio)))
+			return 0;
+
+		if (adata->polling) {
+			udelay(50);
+		} else {
+			adata->done = false;
+			adata->status = 0;
+			wait_event_timeout(adata->wait, adata->done,
+					   adap->timeout);
+		}
+
+	} while (time_before(jiffies, timeout));
+
+	return -EBUSY;
+}
+
+int sam_i2c_calc_start_entry(struct i2c_msg *msgs, int num, int reverse_fill)
+{
+	int i, len = 0;
+
+	/* Filling the table from start (offset 0) ? */
+	if (!reverse_fill)
+		return 0;
+
+	/* Calculate required table size from the message sizes */
+	if (num == 1 && msgs[0].len == 0)
+		len = 1;
+	else
+		for (i = 0; i < num; i++)
+			if (msgs[i].flags & I2C_M_RECV_LEN)
+				len += (I2C_SMBUS_BLOCK_MAX + 1);
+			else
+				len += msgs[i].len;
+
+	if (len > SAM_I2C_CMD_TABLE_SZ * 2)
+		return -E2BIG;
+
+	/* Always start from Command 0 */
+	return (SAM_I2C_CMD_TABLE_SZ * 2 - len) / 2;
+}
+
+static int sam_i2c_cmd_init(struct i2c_adapter *adap, struct i2c_msg *msgs,
+			    int num)
+{
+	struct sam_i2c_adapdata *adata = i2c_get_adapdata(adap);
+	struct device *dev = &adap->dev;
+	struct i2c_msg *msg;
+	int curmsg, cmds = 0;
+	int addr, i, len = 0, table_offset = 0;
+	u32 cmd_entry;
+	bool read;
+	u8 group;
+	u32 idx;
+	u8 cmd;
+
+	group = adata->mux_select;
+	addr = msgs[0].addr & SAM_I2C_DEV_ADDR_MASK;
+	cmd_entry = (group << 29) | (addr << 22);
+
+	/* Zero CMD table */
+	memset_io(CMD_ADDR(adata, 0), 0, SAM_I2C_CMD_TABLE_SZ * sizeof(u32));
+
+	idx = sam_i2c_calc_start_entry(msgs, num, adata->reverse_fill);
+	if (idx < 0)
+		return idx;
+
+	table_offset = idx;
+
+	for (curmsg = 0; curmsg < num; curmsg++) {
+		msg = &msgs[curmsg];
+		read = msg->flags & I2C_M_RD;
+
+		SAM_DEB1(dev, "  [%02d] %s %d bytes addr %#02x\n",
+			 curmsg, read ? "RD" : "WR",
+			 msg->len, addr);
+
+		len = msg->len;
+		if (len == 0 && curmsg == 0 && num == 1) {
+			/*
+			 * SMBus quick command, special case
+			 *
+			 * Always read; we don't want to risk that
+			 * a "WRITE_STOP" command as only command
+			 * would actually write anything into the chip.
+			 */
+			cmd = I2C_READ_STOP;
+			cmd_entry |= cmd << 19;
+			cmds = 1;
+			break;
+		}
+		/*
+		 * If the message is a SMBus block read message, read up to the
+		 * maximum block length. The command should succeed at least up
+		 * to the real block length, which will be returned in the first
+		 * data byte.
+		 */
+		if (read && (msg->flags & I2C_M_RECV_LEN))
+			len = I2C_SMBUS_BLOCK_MAX + 1;
+		for (i = 0; i < len; i++) {
+			cmd = read ? I2C_READ : I2C_WRITE;
+			if (i == len - 1) {
+				if (curmsg == num - 1)
+					cmd |= I2C_CMD_STOP_BIT;
+				else
+					cmd |= I2C_CMD_REPSTART_BIT;
+			}
+
+			if ((cmds % SAM_I2C_TBL_ENTRY_CMDS_NUM) == 0) {
+				/* cmd0/data0 */
+				cmd_entry |= cmd << 19;
+				if (!read)
+					cmd_entry |= (msg->buf[i] << 11);
+			} else {
+				/* cmd1/data1 */
+				cmd_entry |= cmd << 8;
+				if (!read)
+					cmd_entry |= msg->buf[i];
+			}
+			cmds++;
+			if (cmds % SAM_I2C_TBL_ENTRY_CMDS_NUM == 0) {
+				/*
+				 * One command entry is done!
+				 * Write it to the command table and start
+				 * putting together the next entry for
+				 * the same current i2c command, if needed.
+				 */
+				SAM_DEB2(dev,
+					 "reg-offset cmd_entry = 0x%08x, cmds = %d, @ %p\n",
+					 cmd_entry, cmds, CMD_ADDR(adata, idx));
+
+				iowrite32(cmd_entry, CMD_ADDR(adata, idx));
+				ioread32(CMD_ADDR(adata, idx));
+				idx++;
+
+				/* clean out everything but group and address */
+				cmd_entry &= 0xFFC00000;
+			}
+		}
+	}
+	/*
+	 * Zero out any remaining cmd/data part of the last
+	 * command entry into the command table of the given
+	 * master before kicking off the i2c engine for this
+	 * master.
+	 */
+	if (cmds % SAM_I2C_TBL_ENTRY_CMDS_NUM != 0) {
+		cmd_entry &= 0xFFFFF800;
+
+		SAM_DEB1(dev, "rest of cmd_entry = 0x%08x, cmds = %d, @ %p\n",
+			 cmd_entry, cmds, CMD_ADDR(adata, idx));
+
+		if (idx >= SAM_I2C_CMD_TABLE_SZ)
+			return -E2BIG;
+
+		iowrite32(cmd_entry, CMD_ADDR(adata, idx));
+		ioread32(CMD_ADDR(adata, idx));
+		idx++;
+		if (idx < SAM_I2C_CMD_TABLE_SZ) {
+			iowrite32(0, CMD_ADDR(adata, idx));
+			ioread32(CMD_ADDR(adata, idx));
+		}
+	}
+	return table_offset;
+}
+
+static u32 i2c_sam_wait_results(struct i2c_adapter *adap)
+{
+	struct sam_i2c_adapdata *adata = i2c_get_adapdata(adap);
+	struct device *dev = &adap->dev;
+	u32 val;
+
+	if (adata->polling) {
+		unsigned long timeout = jiffies + adap->timeout;
+
+		/*
+		 * Poll for results.
+		 * Only wait a short time per loop to avoid long access times.
+		 * At 100kHz, a single byte transfer takes about 100 uS,
+		 * so we don't want to wait much longer than that.
+		 */
+		do {
+			/*
+			 * We should really use usleep_range() here, but that
+			 * does not work and causes the system to lock up.
+			 * msleep() is slow, so use an active wait loop instead.
+			 */
+			udelay(50);
+			val = ioread32(STAT_ADDR(adata));
+			SAM_DEB1(dev, "status = 0x%08x @%p\n",
+				 val, STAT_ADDR(adata));
+			if (STS_I2C_DONE(val, adata->prio))
+				break;
+		} while (time_before(jiffies, timeout));
+	} else {
+		if (!wait_event_timeout(adata->wait, adata->done,
+					adap->timeout))
+			val = ioread32(STAT_ADDR(adata));
+		else
+			val = ioread32(STAT_ADDR(adata)) | adata->status;
+	}
+
+	sam_i2c_stat_clear(adata, val);
+
+	return val;
+}
+
+static int sam_i2c_read_data(struct i2c_adapter *adap, struct i2c_msg *msgs,
+			     int num, int table_offset)
+{
+	struct sam_i2c_adapdata *adata = i2c_get_adapdata(adap);
+	int offset = table_offset * 2;
+	struct device *dev = &adap->dev;
+	struct i2c_msg *msg;
+	u32 val, data;
+	bool valid;
+	int i, len;
+
+	msg = &msgs[num - 1];
+	len = msg->len;
+
+	if (num > 1)
+		offset += msgs[0].len;
+
+	SAM_DEB1(dev, "Reading %d bytes\n", len);
+
+	for (i = offset & 0xfffffffe; i < len + offset; i++) {
+		val = ioread32(RES_ADDR(adata, i / 2));
+		SAM_DEB2(dev, "data = 0x%08x @%p\n",
+			 val, RES_ADDR(adata, i / 2));
+		if (i >= offset) {
+			data = (val >> 11) & 0xff;	/* data_0  */
+			valid = val & 0x00200000;	/* valid_0 */
+			if (!valid)
+				return -EIO;
+			msg->buf[i - offset] = data;
+			if (i == offset &&
+			    (msg->flags & I2C_M_RECV_LEN)) {
+				if (data == 0 ||
+				    data > I2C_SMBUS_BLOCK_MAX)
+					return -EPROTO;
+				SAM_DEB1(dev, "SMBus block data, %d bytes\n",
+					 data);
+				len += data;
+			}
+		}
+		if (++i >= len + offset)
+			break;
+		if (i >= offset) {
+			data = val & 0xff;		/* data_1  */
+			valid = val & 0x00000400;	/* valid_1 */
+			if (!valid)
+				return -EIO;
+			msg->buf[i - offset] = data;
+			if (i == offset &&
+			    (msg->flags & I2C_M_RECV_LEN)) {
+				if (data == 0 ||
+				    data > I2C_SMBUS_BLOCK_MAX)
+					return -EPROTO;
+				SAM_DEB1(dev, "SMBus block data, %d bytes\n",
+					 data);
+				len += data;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static int sam_i2c_xfer(struct i2c_adapter *adap, struct i2c_msg *msgs, int num)
+{
+	struct sam_i2c_adapdata *adata = i2c_get_adapdata(adap);
+	int ret, table_offset;
+	u32 val;
+
+	ret = sam_i2c_wait_rdy(adap);
+	if (ret < 0)
+		return ret;
+
+	ret = sam_i2c_cmd_init(adap, msgs, num);
+	if (ret < 0)
+		return ret;
+	table_offset = ret & 0xff;
+
+	sam_i2c_stat_clear(adata, ioread32(STAT_ADDR(adata)));
+
+	/*
+	 * Done with setting up the command table, now kick
+	 * off this transaction before waiting for the results.
+	 */
+
+	adata->done = false;
+	adata->status = 0;
+
+	iowrite32(adata->control | CTRL_GO(adata->prio) | table_offset << 24,
+		  CTRL_ADDR(adata));
+	ioread32(CTRL_ADDR(adata));	/* read back to flush */
+
+	val = i2c_sam_wait_results(adap);
+	if (val & STS_ERR(adata->prio)) {
+		dev_err(&adap->dev, "i2c transaction error\n");
+		return -EIO;
+	}
+	if ((val & SAM_I2C_STS_TIMEOUT) || !(val & STS_DONE(adata->prio))) {
+		SAM_DEB1(&adap->dev,
+			 "i2c transaction timeout, status=0x%x\n", val);
+		return -ETIMEDOUT;
+	}
+
+	SAM_DEB1(&adap->dev, "i2c transaction completed!!!\n");
+
+	/* SMBus quick command, special case */
+	if (num == 1 && msgs[0].len == 0) {
+		val = ioread32(RES_ADDR(adata, table_offset));
+		SAM_DEB1(&adap->dev, "quick cmd: data = 0x%08x\n", val);
+		return val & 0x00200000 ? 1 : -EIO;
+	}
+	/*
+	 * If this was a "read" request, go get the data.
+	 * Otherwise, we're done here!
+	 */
+	if (msgs[num - 1].flags & I2C_M_RD) {
+		ret = sam_i2c_read_data(adap, msgs, num, table_offset);
+		if (ret < 0)
+			return ret;
+	}
+
+	SAM_DEB1(&adap->dev, "Returning %d\n", num);
+	return num;
+}
+
+static u32 sam_i2c_func(struct i2c_adapter *adap)
+{
+	return I2C_FUNC_I2C | I2C_FUNC_SMBUS_EMUL
+	  | I2C_FUNC_SMBUS_READ_BLOCK_DATA;
+}
+
+static const struct i2c_algorithm sam_i2c_algo = {
+	.master_xfer = sam_i2c_xfer,
+	.functionality = sam_i2c_func,
+};
+
+/*
+ * This is where the SAM I2C-accel needs to be initialized.
+ */
+static int sam_i2c_init_adap(struct i2c_adapter *adap)
+{
+	struct sam_i2c_adapdata *adata = i2c_get_adapdata(adap);
+	u32 val;
+
+	SAM_DEB1(&adap->dev, "bus_mstr = %d\n", adata->channel);
+
+	val = 0x00000f00;
+	val |= (adata->speed << 12) & 0x0000f000;
+	adata->control = val;
+	/*
+	 * Set the i2c speed for ALL ports of this master and enable them all
+	 */
+	iowrite32(val, CTRL_ADDR(adata));
+
+	return 0;
+}
+
+int sam_i2c_add_numbered_bus(struct i2c_adapter *adap)
+{
+	int rval;
+
+	SAM_DEB1(&adap->dev, "%s", __func__);
+
+	rval = sam_i2c_init_adap(adap);
+	if (rval)
+		return rval;
+
+	return i2c_add_numbered_adapter(adap);
+}
+/********** end of i2c adapter/accel stuff ************************************/
+
+/********** start of i2c accel mux/group stuff ********************************/
+static int sam_i2c_mux_select(struct i2c_mux_core *muxc, u32 chan)
+{
+	struct sam_i2c_adapdata *adata = i2c_mux_priv(muxc);
+
+	if (!adata)
+		return -ENODEV;
+	adata->mux_select = chan;
+
+	return 0;
+}
+
+static int sam_i2c_mux_init(struct i2c_adapter *adap)
+{
+	struct sam_i2c_adapdata *adata = i2c_get_adapdata(adap);
+	int chan, ret;
+
+	SAM_DEB1(&adap->dev, "%s Begin\n", __func__);
+
+	adata->muxc = i2c_mux_alloc(adap, &adap->dev, adata->mux_channels, 0, 0,
+				   sam_i2c_mux_select, NULL);
+	if (!adata->muxc)
+		return -ENOMEM;
+	adata->muxc->priv = adata;
+
+	for (chan = 0; chan < adata->mux_channels; chan++) {
+		ret = i2c_mux_add_adapter(adata->muxc, 0, chan, 0);
+		if (ret) {
+			dev_err(&adap->dev, "Failed to add adapter %d\n", chan);
+			i2c_mux_del_adapters(adata->muxc);
+			return ret;
+		}
+	}
+
+	SAM_DEB1(&adap->dev, "%s End\n", __func__);
+
+	return 0;
+}
+
+/********** end of i2c accel mux/group stuff **********************************/
+
+static void sam_core_of_init_options(struct device *dev,
+				     struct sam_i2c_data *sam)
+{
+	const __be32 *opt;
+	int len, i;
+
+	opt = of_get_property(dev->of_node, "i2c-options", &len);
+	if (!opt || len > 4 * sizeof(u32))
+		return;
+
+	for (i = 0; i < len; i += sizeof(u32))
+		iowrite32(be32_to_cpup(opt++),
+			  sam->membase + I2C_OPTIONS_BASE + i);
+}
+
+static int sam_core_of_init(struct device *dev, struct sam_i2c_data *sam,
+			    struct resource *res)
+{
+	int err;
+	int num_master, max_masters;
+	u32 speed, mux_channels, val, master_offset = MASTER_MEM_BASE;
+	int i, len;
+	const __be32 *bus_range, *regs;
+	struct device_node *child;
+	u32 master, mux;
+
+	num_master = ioread32(sam->membase + 0x0c);
+	sam->first_master = -1;
+
+	err = of_property_read_u32(dev->of_node, "master-offset", &val);
+	if (!err)
+		if (val + PER_MASTER_MEM <= resource_size(res)) {
+			master_offset = val;
+			dev_info(dev, "Master offset changed to 0x%08x", val);
+		}
+
+	sam->masterbase = sam->membase + master_offset;
+	max_masters = (resource_size(res) - master_offset) / PER_MASTER_MEM;
+
+	if (num_master <= 0 || num_master > max_masters)
+		return -EINVAL;
+	sam->num_master = num_master;
+
+	bus_range = of_get_property(dev->of_node, "i2c-bus-range", &len);
+	if (bus_range) {
+		if (len != 2 * sizeof(u32))
+			return -EINVAL;
+		sam->first_master = be32_to_cpu(bus_range[0]);
+		num_master = be32_to_cpu(bus_range[1]) - sam->first_master + 1;
+		if (num_master <= 0 || num_master > sam->num_master)
+			return -EINVAL;
+		sam->num_master = num_master;
+	}
+
+	sam->speed = devm_kcalloc(dev, sam->num_master, sizeof(u32),
+				  GFP_KERNEL);
+	if (!sam->speed)
+		return -ENOMEM;
+
+	sam->adap = devm_kcalloc(dev, sam->num_master,
+				 sizeof(struct i2c_adapter *), GFP_KERNEL);
+	if (!sam->adap)
+		return -ENOMEM;
+
+	/* Set default i2c speed to 100kHz for all channels */
+	for (i = 0; i < sam->num_master; i++)
+		sam->speed[i] = (1 << SAM_I2C_MUX_MAX_CHAN) - 1;
+
+	if (!dev->of_node) {
+		/*
+		 * Use default from platform data if the there is no FDT.
+		 * TODO: Use FDT once it is available
+		 */
+		sam->mux_channels = sam->pdata ?
+			sam->pdata->i2c_mux_channels : 2;
+		dev_warn(dev,
+			 "No FDT node for SAM, using default (%d)\n",
+			 sam->mux_channels);
+		return 0;
+	}
+
+	err = of_property_read_u32(dev->of_node, "mux-channels", &mux_channels);
+	if (err || !mux_channels || mux_channels > SAM_I2C_MUX_MAX_CHAN)
+		return -EINVAL;
+	sam->mux_channels = mux_channels;
+	sam->reverse_fill = of_property_read_bool(dev->of_node, "reverse-fill");
+	sam->prio = of_property_read_bool(dev->of_node, "priority-tables");
+	/* Priority tables are offset with 0x800 from the regular tables */
+	if (sam->prio)
+		sam->masterbase += 0x800;
+
+	for_each_child_of_node(dev->of_node, child) {
+		regs = of_get_property(child, "reg", &len);
+		if (!regs || len != 2 * sizeof(u32)) {
+			dev_err(dev, "did not find reg property or bad size\n");
+			return -EINVAL;
+		}
+		err = of_property_read_u32(child, "speed", &speed);
+		if (err || !speed)
+			continue;
+		if (speed != 100000 && speed != 400000) {
+			dev_err(dev, "Bad speed %d\n", speed);
+			return -EINVAL;
+		}
+		master = be32_to_cpu(regs[0]);
+		mux = be32_to_cpu(regs[1]);
+		if (master >= sam->num_master || mux >= sam->mux_channels) {
+			dev_err(dev,
+				"master/mux %d/%d out of range\n",
+				master, mux);
+			return -EINVAL;
+		}
+		if (speed == 400000)
+			sam->speed[master] &= ~(1 << mux);
+	}
+
+	sam_core_of_init_options(dev, sam);
+
+	return 0;
+}
+
+static struct i2c_adapter *sam_i2c_init_one(struct sam_i2c_data *sam,
+					    int channel)
+{
+	struct device *dev = sam->dev;
+	struct sam_i2c_adapdata *adata;
+	int err;
+
+	adata = devm_kzalloc(dev, sizeof(*adata), GFP_KERNEL);
+	if (!adata)
+		return ERR_PTR(-ENOMEM);
+
+	init_waitqueue_head(&adata->wait);
+	adata->adap.owner = THIS_MODULE;
+	adata->adap.algo = &sam_i2c_algo;
+	adata->adap.nr = (sam->first_master >= 0) ?
+			  sam->first_master + channel : -1;
+	adata->adap.timeout = HZ / 5;
+	adata->channel = channel;
+	adata->mux_channels = sam->mux_channels;
+	adata->membase = sam->membase;
+	adata->masterbase = sam->masterbase;
+	adata->speed = sam->speed[channel];
+	adata->polling = (sam->irq < 0);
+	adata->reverse_fill = sam->reverse_fill;
+	adata->prio = sam->prio & 1;
+	i2c_set_adapdata(&adata->adap, adata);
+	snprintf(adata->adap.name, sizeof(adata->adap.name),
+		 "%s:%d", dev_name(dev), channel);
+
+	adata->adap.dev.parent = dev;
+	err = sam_i2c_add_numbered_bus(&adata->adap);
+	if (err)
+		goto error;
+
+	err = sam_i2c_mux_init(&adata->adap);
+	if (err)
+		goto err_remove;
+
+	return &adata->adap;
+
+err_remove:
+	i2c_del_adapter(&adata->adap);
+error:
+	return ERR_PTR(err);
+}
+
+static void sam_i2c_cleanup_one(struct i2c_adapter *adap)
+{
+	struct sam_i2c_adapdata *adata = i2c_get_adapdata(adap);
+
+	i2c_mux_del_adapters(adata->muxc);
+	i2c_del_adapter(adap);
+}
+
+static irqreturn_t sam_i2c_irq_handler(int irq, void *data)
+{
+	struct sam_i2c_data *sam = data;
+	struct sam_platform_data *pdata = sam->pdata;
+	struct sam_i2c_adapdata *adata;
+	int bit;
+	u32 val, status, wake_status;
+	u32 mask = (1 << sam->num_master) - 1;
+
+	status = pdata->irq_status(sam->dev->parent, SAM_IRQ_I2C,
+				   sam->irq) & mask;
+	do {
+		wake_status = status;
+		/* Clear the 'done' bits */
+		while (status) {
+			bit = __ffs(status);
+			status &= ~BIT(bit);
+			adata = i2c_get_adapdata(sam->adap[bit]);
+			val = ioread32(STAT_ADDR(adata));
+			if (STS_I2C_DONE(val, adata->prio)) {
+				sam_i2c_stat_clear(adata, val);
+				if (!adata->done) {
+					adata->done = true;
+					adata->status = val;
+				}
+			}
+		}
+		/*
+		 * Clear the status bits *after* the done status is cleared,
+		 * as otherwise this will generate another unused interrupt.
+		 * On the CBC this will also clear the MSI INT_ACCELL.
+		 */
+		pdata->irq_status_clear(sam->dev->parent, SAM_IRQ_I2C, sam->irq,
+					wake_status);
+
+		/* Now wake the blocked transactions */
+		while (wake_status) {
+			bit = __ffs(wake_status);
+			wake_status &= ~BIT(bit);
+			adata = i2c_get_adapdata(sam->adap[bit]);
+			wake_up(&adata->wait);
+		}
+
+		/* Recheck the status again, as we might miss an MSI in
+		 * the window from the last check and the clear of the
+		 * pending interrupts. This does not affect the SAM INTx.
+		 */
+		status = pdata->irq_status(sam->dev->parent, SAM_IRQ_I2C,
+					   sam->irq) & mask;
+	} while (status);
+
+	return IRQ_HANDLED;
+}
+
+static const struct of_device_id sam_i2c_of_match[] = {
+	{ .compatible = "jnx,i2c-sam",},
+	{},
+};
+MODULE_DEVICE_TABLE(of, sam_i2c_of_match);
+
+
+static int sam_i2c_probe(struct platform_device *pdev)
+{
+	int err;
+	int i;
+	struct sam_i2c_data *sam;
+	struct i2c_adapter *adap;
+	struct resource *res;
+	struct device *dev = &pdev->dev;
+	struct sam_platform_data *pdata = dev_get_platdata(&pdev->dev);
+
+	/*
+	 * Allocate memory for the SAM FPGA info
+	 */
+	sam = devm_kzalloc(dev, sizeof(*sam), GFP_KERNEL);
+	if (!sam)
+		return -ENOMEM;
+
+	platform_set_drvdata(pdev, sam);
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENODEV;
+
+	if (pdata)
+		sam->irq = platform_get_irq(pdev, 0);
+
+	sam->membase = devm_ioremap_nocache(dev, res->start,
+					    resource_size(res));
+	if (!sam->membase)
+		return -ENOMEM;
+
+	sam->dev = dev;
+	sam->pdata = pdata;
+
+	err = sam_core_of_init(dev, sam, res);
+	if (err)
+		return err;
+
+	/***** i2c init *****/
+
+	for (i = 0; i < sam->num_master; i++) {
+		adap = sam_i2c_init_one(sam, i);
+		if (IS_ERR(adap)) {
+			err = PTR_ERR(adap);
+			dev_err(dev,
+				"Failed to initialize adapter %d [base %d, index %d]: %d\n",
+				sam->first_master + i, sam->first_master, i,
+				err);
+			goto err_remove;
+		}
+		sam->adap[i] = adap;
+	}
+
+	if (sam->irq >= 0) {
+		err = devm_request_any_context_irq(dev, sam->irq,
+						sam_i2c_irq_handler, 0,
+						dev_name(dev), sam);
+		if (err < 0) {
+			dev_err(dev, "Failed to request interrupt %d: %d\n",
+				sam->irq, err);
+			goto err_remove;
+		}
+		pdata->enable_irq(dev->parent, SAM_IRQ_I2C, sam->irq,
+				  (1 << sam->num_master) - 1);
+	}
+
+	return 0;
+
+err_remove:
+	for (i--; i >= 0; i--)
+		sam_i2c_cleanup_one(sam->adap[i]);
+	return err;
+}
+
+static int sam_i2c_remove(struct platform_device *pdev)
+{
+	struct sam_i2c_data *sam = platform_get_drvdata(pdev);
+	struct sam_platform_data *pdata = sam->pdata;
+	int i;
+
+	if (sam->irq >= 0 && pdata)
+		pdata->disable_irq(pdev->dev.parent, SAM_IRQ_I2C, sam->irq,
+			(1 << sam->num_master) - 1);
+	for (i = 0; i < sam->num_master; i++)
+		sam_i2c_cleanup_one(sam->adap[i]);
+
+	return 0;
+}
+
+static struct platform_driver sam_i2c_driver = {
+	.driver = {
+		.name   = "i2c-sam",
+		.owner  = THIS_MODULE,
+		.of_match_table = sam_i2c_of_match,
+	},
+	.probe  = sam_i2c_probe,
+	.remove = sam_i2c_remove,
+};
+
+module_platform_driver(sam_i2c_driver);
+
+MODULE_DESCRIPTION(DRIVER_DESC);
+MODULE_VERSION(DRIVER_VERSION);
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR(DRIVER_AUTHOR);
+
+module_param(sam_debug, int, S_IWUSR | S_IRUGO);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
