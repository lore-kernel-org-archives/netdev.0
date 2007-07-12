From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Thu, 12 Jul 2007 15:51:49 +0200
Message-ID: <469631F5.7080207@trash.net>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47629 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933237AbXGLNwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 09:52:11 -0400
In-Reply-To: <4695F214.6020401@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> +	if (data != NULL && data[VETH_INFO_PEER] != NULL) {
> +		err = nla_parse_nested(tb, IFLA_INFO_MAX,
> +				data[VETH_INFO_PEER], ifla_policy);
> +		if (err < 0)
> +			return err;
> +	}


One more suggestion regarding the PEER attribute: you only nest
IFLA attributes below it, but some information that might be
interesting to use on device creation is contained in ifinfomsg
(flags and ifindex). So I think it would be better to use a
complete message, including header.


