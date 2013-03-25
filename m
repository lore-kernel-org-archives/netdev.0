From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Mon, 25 Mar 2013 14:39:23 -0400 (EDT)
Message-ID: <20130325.143923.762657816602656826.davem@davemloft.net>
References: <1364209702-12437-3-git-send-email-wei.liu2@citrix.com>
	<20130325.121809.2023305728304341952.davem@davemloft.net>
	<20130325183206.GA7004@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Ian.Campbell@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com, david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932611Ab3CYSj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 14:39:27 -0400
In-Reply-To: <20130325183206.GA7004@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 25 Mar 2013 18:32:06 +0000

> On Mon, Mar 25, 2013 at 04:18:09PM +0000, David Miller wrote:
>> From: Wei Liu <wei.liu2@citrix.com>
>> Date: Mon, 25 Mar 2013 11:08:18 +0000
>> 
>> > The maximum packet including ethernet header that can be handled by netfront /
>> > netback wire format is 65535. Reduce gso_max_size accordingly.
>> > 
>> > Drop skb and print warning when skb->len > 65535. This can 1) save the effort
>> > to send malformed packet to netback, 2) help spotting misconfiguration of
>> > netfront in the future.
>> > 
>> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>> 
>> This is effectively the default already, you don't need to change this
>> value explicitly.
>> 
>> ->gso_max_size is set by default to 65536 and then TCP performs this
>> calculation:
>> 
>>                 xmit_size_goal = ((sk->sk_gso_max_size - 1) -                          
>>                                   inet_csk(sk)->icsk_af_ops->net_header_len -          
>>                                   inet_csk(sk)->icsk_ext_hdr_len -                     
>>                                   tp->tcp_header_len);                                 
> 
> OK. But I see similar fix for a physical nic (commit b7e5887e0e414b), am
> I missing something here?
> 
> And the symptom is that if I don't reserve headroom I see skb->len =
> 65538. Can you shed some light on this?

See Eric's reply.  If a GRO frame is forwarded we don't make the GSO size
checks on the send size as we should.
