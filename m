From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv9] macvlan: add source mode
Date: Fri, 14 Mar 2014 09:12:35 -0700
Message-ID: <20140314091235.14bc24e4@nehalam.linuxnetplumber.net>
References: <1394797786-27420-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>,
	<projekt-wlan@fem.tu-ilmenau.de>, Stefan Gula <steweg@gmail.com>
To: Michael Braun <michael-dev@fami-braun.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:46504 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705AbaCNQMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 12:12:46 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so2837382pad.2
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 09:12:45 -0700 (PDT)
In-Reply-To: <1394797786-27420-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Mar 2014 12:49:46 +0100
Michael Braun <michael-dev@fami-braun.de> wrote:

> +static void macvlan_forward_sources(struct sk_buff *skb,
> +				    struct macvlan_port *port,
> +				    const unsigned char *addr)
> +{
> +	struct macvlan_source_list *list;
> +	struct hlist_head *h = &port->vlan_source_hash[addr[5]];
> +

If you are going to use a hash table, better to use a real hash function.
It could be as simple as jhash, or you could be faster/smaller
by putting ether address into 64 bit number and using hash_64.
