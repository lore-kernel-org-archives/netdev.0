From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH net-next 1/3] ixgbe: support netdev_ops->ndo_xmit_flush()
Date: Tue, 26 Aug 2014 08:13:43 +0200
Message-ID: <53FC2597.4050501@redhat.com>
References: <1408887738-7661-2-git-send-email-dborkman@redhat.com> <20140825140721.162a6c91@redhat.com> <20140825.153248.1202565040217198094.davem@davemloft.net> <20140825.163135.1716545240924138406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34036 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757046AbaHZGNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 02:13:50 -0400
In-Reply-To: <20140825.163135.1716545240924138406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2014 01:31 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 25 Aug 2014 15:32:48 -0700 (PDT)
>
>> Jesper, just for fun, could you revert all of the xmit flush stuff and
>> test this patch instead?
>
> This doesn't work properly, sorry.  We need to explicitly set xmit_more
> to zero before ->ndo_start_xmit() calls, because the initial zero'ing
> of that value isn't propagated in copy_skb_header() (nor do we want to
> add that).
>
> But I'm beyond convinced now that ->ndo_xmit_flush() is not the way to
> do this.
>
> I'm about to post a set of patches which will go into net-next which:
>
> 1) Converts the tree to skb->xmit_more
>
> 2) Adds Daniel's IXGBE conversion, adjusted for xmit_more.

This seems indeed a better, more lightweight version to accomplish it.
