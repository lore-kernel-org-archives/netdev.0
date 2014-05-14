From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/8] bridge: Keep track of ports capable of
 automatic discovery.
Date: Wed, 14 May 2014 08:42:51 -0700
Message-ID: <20140514084251.317ed026@nehalam.linuxnetplumber.net>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
	<1400080168-16625-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	shemminger@vyatta.com, mst@redhat.com, john.r.fastabend@intel.com,
	jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48462 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbaENPm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 11:42:59 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so1821886pab.5
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 08:42:58 -0700 (PDT)
In-Reply-To: <1400080168-16625-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2014 11:09:22 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> @@ -58,6 +61,7 @@ static int store_flag(struct net_bridge_port *p, unsigned long v,
>  
>  	if (flags != p->flags) {
>  		p->flags = flags;
> +		br_port_flags_change(p, old_flags ^ flags);

You are also xoring twice.

Why not:

store_flag()
	if (flags != p->flags) {
		br_port_flags_change(p, flags);
		p->flags = flags;
		br_ifinfo_notify(RTM_NEWLINK, p);
