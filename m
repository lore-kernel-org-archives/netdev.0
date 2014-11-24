From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] Add support of Cavium Liquidio ethernet adapters
Date: Mon, 24 Nov 2014 13:01:06 -0800
Message-ID: <54739C92.5070309@gmail.com>
References: <1416799190-23789-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:39834 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaKXVBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:01:22 -0500
Received: by mail-pd0-f182.google.com with SMTP id r10so10509500pdi.13
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 13:01:21 -0800 (PST)
In-Reply-To: <1416799190-23789-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2014 07:19 PM, Raghu Vatsavayi wrote:
> +if LIQUIDIO
> +
> +config LIQUIDIO_NAPI
> +	bool "Enable NAPI for LiquidIO"
> +	default y
> +	---help---
> +	  NAPI is a new driver API designed to reduce CPU and interrupt load
> +	  when the driver is receiving lots of packets from the card. You
> +	  would only disable this feature in very specific instances, like
> +	  an application that very rapidly sets up and tears down connections.
> +
> +	  If in doubt, say Y.

You probably do not want to offer a non-NAPI variant, pretty much all
drivers have NAPI built-in now.

> +
> +config LIQUIDIO_DEBUG
> +	int "Debug level for LiquidIO"
> +	range 0 4
> +	default 0
> +	---help---
> +	  Enables more extensive debug output. This may negatively
> +	  affect performance, so use values > 0 with caution.
> +	  0 disables extra debug
> +	  1 enables general messages
> +	  2 enables register access messages
> +	  3 enables debug messages
> +	  4 enables flow messages
> +
> +	  If in doubt, say 0.

This should be moved to dynamic_debug/ethtools' msglvl control knob.
--
Florian
