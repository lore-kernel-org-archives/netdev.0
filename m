From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] rt2x00 drivers: rt61pci
Date: Sat, 29 Apr 2006 16:58:50 +0200
Message-ID: <20060429145850.GA2456@electric-eye.fr.zoreil.com>
References: <200604291147.26887.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36311 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750736AbWD2O7l
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 10:59:41 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200604291147.26887.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ivo van Doorn <ivdoorn@gmail.com> :
> From: Ivo van Doorn <IvDoorn@gmail.com>
> 
> This adds the rt61pci driver to the tree 
> 
> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
> 
> Available on server:
> http://mendiosus.nl/rt2x00/rt61pci.diff

It is nice that you are doing this work but I still don't feel
the same while reading your patches or tg3.c/sky2.c (for instance).

+static inline void
+rt2x00_register_read(

grep accepts regular expression and ctags works quite well.
Why do you cut an expression which would fit on a 80 columns line ?

[...]
+	u32		reg;
+	u8		counter;

It's (mostly) fine with me if you want to align the declaration
but why do you use more than the minimum amount of required tab ?
Elsewhere the variable is completely shifted right: beyond a point,
it does not make the code more readable.

Not sure if 'unsigned int' would be welcome instead of 'u8' for
counter.

[...]
+	for (counter = 0; counter < REGISTER_BUSY_COUNT; counter++) {
+		rt2x00_register_read(rt2x00pci, PHY_CSR3, &reg);

"i" is more idiomatic C-kernel than "counter".

[...]
+	if (rt2x00_rf(&rt2x00pci->chip, RF5225)
+	|| rt2x00_rf(&rt2x00pci->chip, RF2527))

If you put the || at the end of the previous line, you can indent
the second line with four withspaces, thus aligning the content.

[...]
+static void
+rt61pci_init_firmware_cont(const struct firmware *fw, void *context)
[...]
+	for (counter = 0; counter < 100; counter++) {
+		rt2x00_register_read(rt2x00pci, MCU_CNTL_CSR, &reg);
+		if (rt2x00_get_field32(reg, MCU_CNTL_CSR_READY))
+			break;
+		msleep(1);
+	}
+
+	if (counter == 1000) {
                          ^ -> typo


[...]
static int
+rt61pci_init_firmware(struct rt2x00_pci *rt2x00pci)
+{
+	/*
+	 * Read correct firmware from harddisk.
+	 */
+	if (rt2x00_rt(&rt2x00pci->chip, RT2561))
+		return request_firmware_nowait(THIS_MODULE, 1,
+			"rt2561.bin", &rt2x00pci->pci_dev->dev, rt2x00pci,
+			rt61pci_init_firmware_cont);
+	else if (rt2x00_rt(&rt2x00pci->chip, RT2561s))
+		return request_firmware_nowait(THIS_MODULE, 1,
+			"rt2561s.bin", &rt2x00pci->pci_dev->dev, rt2x00pci,
+			rt61pci_init_firmware_cont);
+	else if (rt2x00_rt(&rt2x00pci->chip, RT2661))
+		return request_firmware_nowait(THIS_MODULE, 1,
+			"rt2661.bin", &rt2x00pci->pci_dev->dev, rt2x00pci,
+			rt61pci_init_firmware_cont);

	struct {
		char *name;
		unsigned int chip;
	} firmware[] = {
		{ "rt2561.bin",		RT2561 },
		{ "rt2561s.bin",	RT2561s },
		{ "rt2561.bin",		RT2661 }
	};
	int rc = -EINVAL;
	unsigned int i;

	for (i = 0; i < ARRAY_SIZE(firmware); i++) {
		if (!rt2x00_rt(&rt2x00pci->chip, firmware[i].chip)) 
			continue;
		rc = request_firmware_nowait(THIS_MODULE, 1,
			firmware[i].name, &rt2x00pci->pci_dev->dev,
			rt2x00pci, rt61pci_init_firmware_cont);
		break;
	}
	return rc;

-- 
Ueimor
