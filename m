From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 3/3] mpls: support for ip tunnels
Date: Sat, 20 Jun 2015 07:42:09 -0700
Message-ID: <55857BC1.6010704@cumulusnetworks.com>
References: <1434689355-4088-4-git-send-email-roopa@cumulusnetworks.com> <55843E15.2040301@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34676 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547AbbFTOmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 10:42:10 -0400
Received: by pabvl15 with SMTP id vl15so57728923pab.1
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2015 07:42:09 -0700 (PDT)
In-Reply-To: <55843E15.2040301@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 9:06 AM, Robert Shearman wrote:
>> +
>> +    /* Push the new labels */
>> +    hdr = mpls_hdr(skb);
>> +    bos = true;
>> +    for (i = tun_encap_info->labels - 1; i >= 0; i--) {
>> +        hdr[i] = mpls_entry_encode(tun_encap_info->label[i],
>> +                       dec.ttl, 0, bos);
>
> dec is never initialised in this function, so this will encode a 
> garbage ttl into the packet.
>
> This should instead be deriving the ttl from the IP packet, as Eric 
> did in his original patch.
>
Thanks for the pointer Robert. I will fix it.
