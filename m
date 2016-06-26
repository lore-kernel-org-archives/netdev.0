From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [ethtool PATCH v1 2/2] ethtool:QSFP Plus/QSFP28 Diagnostics
 Information Support
Date: Sun, 26 Jun 2016 23:41:16 +0300
Message-ID: <CAKoUArk=MsPCXFgXkkdACQwpk+X1ionXO_yJm_=8kpHjrLXOZw@mail.gmail.com>
References: <1465860426-30387-3-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ben@decadent.org.uk, Netdev <netdev@vger.kernel.org>,
	bwh@kernel.org, David Miller <davem@davemloft.net>,
	bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	gospo@cumulusnetworks.com, dustin@cumulusnetworks.com
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34053 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbcFZUlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 16:41:46 -0400
Received: by mail-lf0-f53.google.com with SMTP id h129so144935640lfh.1
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2016 13:41:18 -0700 (PDT)
In-Reply-To: <1465860426-30387-3-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vidya,
Thanks a lot for your your work!

Here are my 2 cents:

> +       /* SFP voltage in 0.1mV units */
> +       __u16 sfp_voltage;
> +       /* SFP Temp in 16-bit signed 1/256 Celcius */
> +       __s16 sfp_temp;
> +       /* [4] tables are low/high warn, low/high alarm */

You already had just 5 lines earlier: /* SFP voltage in 0.1mV units */
Shouldn't it be: /* SFP threshold voltage in 0.1mV units */ ?

> +       /* SFP voltage in 0.1mV units */
> +       __u16 thresh_sfp_voltage[4];


pagging should be: paging,
support_alarms should be:supports_alarms
> +        * If pagging support exists, then support_alarms is marked as 1
> +        */
> +
+       if (eeprom_len == ETH_MODULE_SFF_8636_MAX_LEN) {
+               if (!(id[SFF8636_STATUS_2_OFFSET] &
+                                       SFF8636_STATUS_PAGE_3_PRESENT)) {
+                       sd.supports_alarms = 1;
+               }
+       }


Shouldn't it be power/ TX bias current fields?  ("current" only once)
> +       /*
> +        * SFF-8636/8436 spec is not clear whether RX power/ TX bias current
> +        * current fields are supported or not. A valid temperature reading
> +        * is used as existence for TX/RX power.

Should it be: SFF-8472/8079   (without "$")?
> + *
> + * Common utilities across SFF-8436/8636 and SFF-8472/8079$
> + * are defined in this file
> + *


Regards,
Rami Rosen
