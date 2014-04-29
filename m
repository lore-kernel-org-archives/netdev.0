From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH RFC 2/2] net: qualcomm: new Ethernet over SPI driver for
 QCA7000
Date: Tue, 29 Apr 2014 08:51:26 +0200
Message-ID: <535F4BEE.4080300@i2se.com>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com> <1398707697-43785-3-git-send-email-stefan.wahren@i2se.com> <5020765.3GuR21cUpi@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:60467 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755614AbaD2Gve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 02:51:34 -0400
In-Reply-To: <5020765.3GuR21cUpi@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am 28.04.2014 22:09, schrieb Arnd Bergmann:
> On Monday 28 April 2014 19:54:57 Stefan Wahren wrote:
>> +/*   Dumps the contents of all SPI slave registers.        */
>> +static int
>> +qcaspi_regs_dump(struct seq_file *s, void *what)
>> +{
>> +	struct reg {
>> +		char *name;
>> +		u32 address;
>> +	};
>> +
>> +	static struct reg regs[] = {
>> +		{ "SPI_REG_BFR_SIZE", SPI_REG_BFR_SIZE },
>> +		{ "SPI_REG_WRBUF_SPC_AVA", SPI_REG_WRBUF_SPC_AVA },
>> +		{ "SPI_REG_RDBUF_BYTE_AVA", SPI_REG_RDBUF_BYTE_AVA },
>> +		{ "SPI_REG_SPI_CONFIG", SPI_REG_SPI_CONFIG },
>> +		{ "SPI_REG_SPI_STATUS", SPI_REG_SPI_STATUS },
>> +		{ "SPI_REG_INTR_CAUSE", SPI_REG_INTR_CAUSE },
>> +		{ "SPI_REG_INTR_ENABLE", SPI_REG_INTR_ENABLE },
>> +		{ "SPI_REG_RDBUF_WATERMARK", SPI_REG_RDBUF_WATERMARK },
>> +		{ "SPI_REG_WRBUF_WATERMARK", SPI_REG_WRBUF_WATERMARK },
>> +		{ "SPI_REG_SIGNATURE", SPI_REG_SIGNATURE },
>> +		{ "SPI_REG_ACTION_CTRL", SPI_REG_ACTION_CTRL }
>> +	};
>> +
>> +	struct qcaspi *qca = s->private;
>> +	int i;
>> +
>> +	for (i = 0; i < (sizeof(regs) / sizeof(struct reg)); i++) {
>> +		u16 value;
>> +
>> +		qcaspi_read_register(qca, regs[i].address, &value);
>> +		seq_printf(s, "%-25s(0x%04x): 0x%04x\n",
>> +			regs[i].name, regs[i].address, value);
>> +	}
>> +
>> +	return 0;
>> +}
> Shouldn't these just come through ethtool --register-dump ?

yes, that's right. But from my point of view this have 2 disadvantages:

- the interface to ethtool needs to be maintained (i'm not sure if i
have all debug information)
- the target platform needs ethtool

>
>> +static irqreturn_t
>> +qcaspi_intr_handler(int irq, void *data)
>> +{
>> +	struct qcaspi *qca = (struct qcaspi *) data;
>> +	qca->intr_req++;
>> +	if (qca->spi_thread &&
>> +		qca->spi_thread->state != TASK_RUNNING)
>> +		wake_up_process(qca->spi_thread);
>> +
>> +	return IRQ_HANDLED;
>> +}
> What is the advantage of using your own thread mechanism for receiving
> data instead of the normal NAPI method?
>
> 	Arnd
>

This mechanism comes from Qualcomm and was originally designed for
Kernel 2.6.35. I never
talked to them.  Currently i don't know how to port this driver to NAPI.
It sounds to me,
that's a lot of work and i need more knowledge.

Is there a porting guide for NAPI?

Does this mean the current state of the driver should better go to staging?

Kind regards,
Stefan
