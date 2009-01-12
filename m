From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] SIS900 show warning if bogus MAC address
Date: Mon, 12 Jan 2009 08:23:10 -0800
Message-ID: <20090112082310.56a9253a@extreme>
References: <20090111084504.GB12226@brownhat.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	venza@brownhat.org
To: Daniele Venzano <venza@brownhat.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56907 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377AbZALQXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 11:23:17 -0500
In-Reply-To: <20090111084504.GB12226@brownhat.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 11 Jan 2009 09:45:04 +0100
Daniele Venzano <venza@brownhat.org> wrote:

> The attached patch modifies the sis900 driver to show a warning at boot
> or module load time to show a message when a null MAC address
> (00:00:00:00:00:00) is read from the the hardware.
> This seems to happen with newer usage of the sis900 chipset, since this
> never came up before.
> 
> Signed-off-by: Daniele Venzano <venza@brownhat.org>
> 
> --
> Daniele Venzano
> http://www.brownhat.org
> 
 /**
+ *      sis900_check_mac_addr - Check the MAc adress for validity
+ *	@net_dev: the net device that has the address to check
+ *
+ * 	Return false (0) if the mac address read from the hardware is
+ * 	composed of all zeros.
+ */
+
+static int __devinit sis900_check_mac_addr(struct net_device *net_dev)
+{
+	int i;
+
+	for (i = 0; i < 6; i++)
+		if (net_dev->dev_addr[i] != 0)
+			return 1;
+
+	return 0;
+}
+

This is a reimplementation of:
        return !is_zero_ether_addr(net_dev->dev_addr);

You probably want to use is_valid_ether_addr() instead.
