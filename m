From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 13/13] net-caif-driver: add CAIF serial driver (ldisc)
Date: Fri, 22 Jan 2010 12:07:43 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079032320E6@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com><1264028130-14364-14-git-send-email-sjur.brandeland@stericsson.com> <20100120153600.6e7ce0b2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<marcel@holtmann.org>, <stefano.babic@babic.homelinux.org>
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:59107 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331Ab0AVLJE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 06:09:04 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20100120153600.6e7ce0b2.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Randy.

Randy Dunlap wrote:
>> +++ b/drivers/net/caif/caif_serial.c
>> +struct net_device *device;
>> +char *ser_ttyname = "/dev/ttyS0";
>> +module_param(ser_ttyname, charp, S_IRUGO);
>> +MODULE_PARM_DESC(ser_ttyname, "TTY to open.");
>> +
> 
> Can't a lot of these data items be static?  (above & below)
Yes, you're right. Thank you.

....
>> +static int start_ldisc(struct ser_device *ser) {
>> +	struct file *f;
>> +	mm_segment_t oldfs;
>> +	struct termios tio;
>> +	int ldiscnr = N_CAIF;
>> +	int ret;
>> +	f = filp_open(ser->tty_name, 0, 0);
>> +	if (IS_ERR(f)) {
>> +		dev_err(&ser->dev->dev, "CAIF cannot open:%s\n", ser->tty_name);
>> +		ret = -EINVAL; +		goto error;
>> +	}
>> +	if (f == NULL || f->f_op == NULL || f->f_op->unlocked_ioctl ==
>> NULL) { +		dev_err(&ser->dev->dev, "TTY cannot do IOCTL:%s\n",
>> +			ser->tty_name); +		ret = -EINVAL;
> 
> I'm thinking that the errcode should be (negative) ENOTTY...

Yes, agree - I'll fix this.


BR/Sjur
