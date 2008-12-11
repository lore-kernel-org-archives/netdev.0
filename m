From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Thu, 11 Dec 2008 13:07:28 +0000
Message-ID: <20081211130728.GB5910@ff.dom.local>
References: <20081209210644.GC3785@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:15074 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455AbYLKNHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 08:07:36 -0500
Received: by nf-out-0910.google.com with SMTP id d3so181642nfc.21
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 05:07:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081209210644.GC3785@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09-12-2008 22:06, Neil Horman wrote:
...
> When executing napi->poll from the netpoll_path, this bit will
> be set. When a driver calls netif_rx_complete, if that bit is set, it will not
> remove the napi_struct from the poll_list.  That work will be saved for the next
> iteration of net_rx_action.

This could be not enough: some drivers, e.g. sky2, call napi_complete()
directly.

Regards,
Jarek P.
