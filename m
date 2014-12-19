From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 18 Dec 2014 23:03:51 -0800
Message-ID: <20141218230351.1feeb5e1@urahara>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:39618 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaLSHEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 02:04:01 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so620422pac.22
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 23:04:01 -0800 (PST)
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 19:25:19 -0800
Raghu Vatsavayi <rvatsavayi@caviumnetworks.com> wrote:

> +	if (linfo->link.s.status) {
> +		ecmd->speed = linfo->link.s.speed;
> +		ecmd->duplex = linfo->link.s.duplex;
> +	} else {
> +		ecmd->speed = -1;
> +		ecmd->duplex = -1;
> +	}
> +

You should SPEED_UNKNOWN and DUPLEX_UNKNOWN (not -1).
and don't set ecmd->speed directly, use
     ethtool_cmd_speed_sed(ecmd, speed)
