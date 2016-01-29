From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: Use notifiers for slave link state detection
Date: Fri, 29 Jan 2016 15:05:55 +0800
Message-ID: <56AB0F53.5080600@gmail.com>
References: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
 <1453371388-30230-1-git-send-email-zyjzyj2000@gmail.com>
 <1453371388-30230-2-git-send-email-zyjzyj2000@gmail.com>
 <7578.1453769012@famine> <56A6E5D1.7070807@gmail.com>
 <10582.1453788049@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, boris.shteinbock@windriver.com,
	emil.s.tantilov@intel.com, zhuyj <zyjzyj2000@gmail.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32987 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbcA2HFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 02:05:31 -0500
Received: by mail-pf0-f193.google.com with SMTP id x125so3355625pfb.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 23:05:31 -0800 (PST)
In-Reply-To: <10582.1453788049@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot.

Maybe this patch is to miimon and notifier. Maybe it is not appropriate to arp monitor.
So the following patch will avoid arp monitor.

Thanks a lot.

Zhu Yanjun

+	/* Because of link flap from the slave interface, it is possilbe that
+	 * the notifiler is NETDEV_UP while the actual link state is down. If
+	 * so, it is not necessary to contiune.
+	 */
+	if (!bond->params.arp_interval) {
+		switch (event) {
+		case NETDEV_UP:
+			if (!link_state)
+				return 0;
+			break;
+
+		case NETDEV_DOWN:
+			if (link_state)
+				return 0;
+			break;
+		}
+	}


On 01/26/2016 02:00 PM, Jay Vosburgh wrote:
> +	/* Because of link flap from the slave interface, it is possilbe that
> +	 * the notifiler is NETDEV_UP while the actual link state is down. If
> +	 * so, it is not necessary to contiune.
> +	 */
> +	switch (event) {
> +	case NETDEV_UP:
> +		if (!link_state)
> +			return 0;
> +		break;
> +
> +	case NETDEV_DOWN:
> +		if (link_state)
> +			return 0;
> +		break;
> +	}
> +
