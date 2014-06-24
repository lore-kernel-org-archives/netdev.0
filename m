From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH v2 2/2] bridge: netlink dump interface at par
 with brctl
Date: Tue, 24 Jun 2014 09:10:18 -0700
Message-ID: <20140624091018.4bde9504@nehalam.linuxnetplumber.net>
References: <1403619319-16131-1-git-send-email-jhs@emojatatu.com>
	<1403619319-16131-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:34005 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965084AbaFXQKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 12:10:22 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so434733pbc.2
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 09:10:21 -0700 (PDT)
In-Reply-To: <1403619319-16131-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jun 2014 10:15:19 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> +			if (filter_dev && (!f->dst || f->dst->dev != filter_dev)) {
> +				if (filter_dev != dev)
> +					goto skip;
> +				else {
> +					/* 
> +					 * !f->dst is a speacial case for bridge
> +					 * It means the MAC belongs to the bridge
> +					 * Therefore need a little more filtering
> +					 * we only want to dump the !f->dst case
> +					 */
> +					if (f->dst)
> +						goto skip;
> +				}

After goto, the else is not needed, and it removes one level of already
deep indentation.

		

			if (filter_dev && (!f->dst || f->dst->dev != filter_dev)) {
				if (filter_dev != dev)
					goto skip;
				/* 
				 * !f->dst is a speacial case for bridge
				 * It means the MAC belongs to the bridge
				 * Therefore need a little more filtering
				 * we only want to dump the !f->dst case
				 */
				if (f->dst)
					goto skip;
