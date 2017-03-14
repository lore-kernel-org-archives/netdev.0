From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next 1/4] gtp: move TEID hash to per socket
 structure
Date: Tue, 14 Mar 2017 13:32:35 +0100 (CET)
Message-ID: <687079207.385041.1489494755160.JavaMail.zimbra@tpip.net>
References: <20170314112548.24027-1-aschultz@tpip.net> <20170314112548.24027-2-aschultz@tpip.net> <20170314113300.GA2992@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: laforge <laforge@gnumonks.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: pablo <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:46489 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750771AbdCNMci (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 08:32:38 -0400
In-Reply-To: <20170314113300.GA2992@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- On Mar 14, 2017, at 12:33 PM, pablo pablo@netfilter.org wrote:

> On Tue, Mar 14, 2017 at 12:25:45PM +0100, Andreas Schultz wrote:
>> @@ -275,9 +280,9 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct
>> sk_buff *skb)
>>  
>>  	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
>>  
>> -	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
>> +	pctx = gtp1_pdp_find(gsk, ntohl(gtp1->tid));
>>  	if (!pctx) {
>> -		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
>> +		pr_debug("No PDP ctx to decap skb=%p\n", skb);
>>  		return 1;
> 
> Again the pr_debug() change has resurrected.

Yes, at that point in the code, there is now ways to resolve the network device.
Therefore the netdev_dbg has to go.

> I already told you: If we are going to have more than one gtp device,
> then this doesn't make sense. I have to repeat things over and over
> again, just because you don't want to rebase your patchset for some
> reason. I don't find any other explaination for this.

Without a PDP context, there is no network device, so netdev_dbg.
 
> So please remove this debugging rather than rendering this completely
> useful.

ACK
 
> Moreover this change has nothing to this patch, so this doesn't break
> the one logical change per patch.

This patch moves the incoming teid has from the network device to the
socket. This means that gtp1_pdp_find needs to change. So this related.
For the debug change, see above why it's related.

Andreas
