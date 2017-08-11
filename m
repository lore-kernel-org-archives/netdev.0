From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Fri, 11 Aug 2017 15:12:05 -0700 (PDT)
Message-ID: <20170811.151205.2131155817966352627.davem@davemloft.net>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753648AbdHKWMG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 18:12:06 -0400
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Bryan.Whitehead@microchip.com>
Date: Fri, 11 Aug 2017 19:47:57 +0000

> +static int lan743x_pci_init(struct lan743x_adapter *adapter,
> +			    struct pci_dev *pdev)
> +{
> +	int ret = -ENODEV;
> +	int bars = 0;
> +	struct lan743x_pci *pci = &adapter->pci;

Please always order local variable declarations from longest to shortest
line (reverse christmas tree format).

> +	pci_set_master(pdev);
> +
> +clean_up:
> +	if (ret) {

It is more intuitive to structure this like:

	return 0;

clean_up:
 ...

> +static u8 __iomem *lan743x_pci_get_bar_address(struct lan743x_adapter *adapter,
> +					       int bar_index)
> +{
> +	u8 __iomem *result = NULL;
> +	struct lan743x_pci *pci = &adapter->pci;

Reverse christmas tree ordering please.

> +static int lan743x_csr_light_reset(struct lan743x_adapter *adapter)
> +{
> +	int result = -EIO;
> +	u32 data;
> +	unsigned long timeout;

Likewise.

> +static inline void lan743x_csr_write(
> +	struct lan743x_adapter *adapter, int offset, u32 data)

Don't do the argument formatting like this please, it looks terrible.

This:

static inline void lan743x_csr_write(struct lan743x_adapter *adapter,
				     int offset, u32 data)

works much better.

> +static void lan743x_intr_union_isr(void *context, u32 int_sts)
> +{
> +	struct lan743x_adapter *adapter = (struct lan743x_adapter *)context;

Casts from void pointers are never necessary, that's the whole point of
void pointers.  Please remove this cast.

> +static irqreturn_t lan743x_vector_isr(int irq, void *ptr)
> +{
> +	irqreturn_t result = IRQ_NONE;
> +	struct lan743x_vector *vector = (struct lan743x_vector *)ptr;
> +	struct lan743x_adapter *adapter = NULL;
> +	u32 int_sts;
> +	u32 mask;

Reverse christmas tree ordering please.

> +static int lan743x_intr_open(struct lan743x_adapter *adapter)
> +{
> +	int ret = -ENODEV;
> +	struct lan743x_intr *intr = &adapter->intr;
> +	int index = 0;

Likewise.

> +static int lan743x_dp_wait_till_not_busy(struct lan743x_adapter *adapter)
> +{
> +	int i;
> +	u32 dp_sel = 0;

Likewise.

> +static int lan743x_dp_write(struct lan743x_adapter *adapter,
> +			    u32 select, u32 addr, u32 length, u32 *buf)
> +{
> +	struct lan743x_dp *dp = &adapter->dp;
> +	int ret = -EIO;
> +	int i;
> +	u32 dp_sel;

Likewise.

> +#ifdef CONFIG_PTP_1588_CLOCK
> +static int lan743x_gpio_reserve_ptp_output(struct lan743x_adapter *adapter,
> +					   int bit, int ptp_channel)
> +{
> +	struct lan743x_gpio *gpio = &adapter->gpio;
> +	int ret = -EBUSY;
> +	unsigned long irq_flags = 0;
> +	int bit_mask = BIT(bit);

Likewise.

> +#ifdef CONFIG_PTP_1588_CLOCK
> +static int lan743x_ptpci_adjfreq(struct ptp_clock_info *ptpci, s32 delta_ppb)
> +{
> +	u32 u32_delta = 0;
> +	u64 u64_delta = 0;
> +	u32 lan743x_rate_adj = 0;
> +	bool positive = true;
> +	struct lan743x_ptp *ptp = LAN743X_PTPCI_TO_PTP;
> +	struct lan743x_adapter *adapter = LAN743X_PTP_TO_ADAPTER;

Likewise.

> +#ifdef CONFIG_PTP_1588_CLOCK
> +static int lan743x_ptpci_adjtime(struct ptp_clock_info *ptpci, s64 delta)
> +{
> +	struct lan743x_ptp *ptp = LAN743X_PTPCI_TO_PTP;
> +	struct lan743x_adapter *adapter = LAN743X_PTP_TO_ADAPTER;

Likewise.

> +#ifdef CONFIG_PTP_1588_CLOCK
> +static int lan743x_ptpci_gettime64(struct ptp_clock_info *ptpci,
> +				   struct timespec64 *ts)
> +{
> +	struct lan743x_ptp *ptp = LAN743X_PTPCI_TO_PTP;
> +	struct lan743x_adapter *adapter = LAN743X_PTP_TO_ADAPTER;

Likewise.

> +#ifdef CONFIG_PTP_1588_CLOCK
> +static int lan743x_ptpci_settime64(struct ptp_clock_info *ptpci,
> +				   const struct timespec64 *ts)
> +{
> +	struct lan743x_ptp *ptp = LAN743X_PTPCI_TO_PTP;
> +	struct lan743x_adapter *adapter = LAN743X_PTP_TO_ADAPTER;

Likewise.

Also, these X_TO_Y macros are terrible.  If you aren an accessor like
that, make it a nice inline function declared in a header file with
lowercase letter which actually does type checking on the pointer
variable which is dereferenced.

> +	if (ts) {
> +		u32 seconds = 0;
> +		u32 nano_seconds = 0;

Reverse christmas tree ordering please.

> +#ifdef CONFIG_PTP_1588_CLOCK
> +static int lan743x_ptp_enable_pps(struct lan743x_adapter *adapter)
> +{
> +	struct lan743x_ptp *ptp = &adapter->ptp;
> +	int result = -ENODEV;
> +	u32 current_seconds = 0;
> +	u32 target_seconds = 0;
> +	u32 general_config = 0;

Likewise.

> +static void lan743x_ptp_isr(void *context)
> +{
> +	int enable_flag = 1;
> +	u32 ptp_int_sts = 0;
> +	struct lan743x_adapter *adapter = (struct lan743x_adapter *)context;
> +	struct lan743x_ptp *ptp = NULL;

Likewise.  And again please remove the void pointer cast.

> +#ifdef CONFIG_PTP_1588_CLOCK
> +static int lan743x_ptp_reserve_event_ch(struct lan743x_adapter *adapter)
> +{
> +	struct lan743x_ptp *ptp = &adapter->ptp;
> +	int index = 0;
> +	int result = -ENODEV;

Likewise.

> +#ifdef CONFIG_PTP_1588_CLOCK
> +static void lan743x_ptp_clock_step(struct lan743x_adapter *adapter,
> +				   s64 time_step_ns)
> +{
> +	struct lan743x_ptp *ptp = &adapter->ptp;
> +	u64 abs_time_step_ns = 0;
> +	s32 seconds = 0;
> +	u32 nano_seconds = 0;

Likewise.

This thing is huge, I'm not reviewing any more of this enormous submission.
