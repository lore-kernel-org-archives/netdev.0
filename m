From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Wed, 10 Feb 2010 09:08:05 -0800
Message-ID: <20100210090805.594b7007@nehalam>
References: <201002100629.o1A6TFUk026363@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36035 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313Ab0BJRIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 12:08:17 -0500
In-Reply-To: <201002100629.o1A6TFUk026363@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Feb 2010 22:29:15 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +		BUG_ON(!(skb));

This driver seems to have lots of extra BUG_ON assertions
which implies either paranoia or still in development.

Putting in a check for NULL in places like this is not really
helpful. The check requires overhead, and will not provide any additional
help to the user. If the BUG_ON() is there the user will see
a backtrace and that cpu will be stuck ... if the BUG_ON was omitted,
and the skb was NULL, user would see a backtrace and cpu would
be stuck.

-- 
