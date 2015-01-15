From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net] be2net: Allow GRE to work concurrently while a
 VxLAN tunnel is configured
Date: Wed, 14 Jan 2015 21:33:57 -0800
Message-ID: <CA+mtBx-tLRi21Sveh-TOmMC0T2cRNqcaEOx2thnqhU-ZLyaN2A@mail.gmail.com>
References: <1421318323-2547-1-git-send-email-sriharsha.basavapatna@emulex.com>
	<CA+mtBx9Kd8JM53RJFJ_R-ZW_FN=UhDQgBNgLNPqadGA9o3ZNiA@mail.gmail.com>
	<31318D46B5DF3F4AB71CC057601E9FEB3A7F5178@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Sriharsha Basavapatna <Sriharsha.Basavapatna@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:41617 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbbAOFd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 00:33:57 -0500
Received: by mail-ig0-f171.google.com with SMTP id z20so26376665igj.4
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 21:33:57 -0800 (PST)
In-Reply-To: <31318D46B5DF3F4AB71CC057601E9FEB3A7F5178@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't understand why this is needed. The only GSO type with with encapsulation allowed by device features SKB_GSO_UDP_TUNNEL. This should not be GRE for instance. Do you see cases where protocol is not UDP at this point?
> [Harsha] It's needed for GRE checksum case; without this,  GRE pkts are sent down without checksum by the stack, but HW
> can only offload checksum for VxLAN pkts.
>
Okay, I see that this is a problem with checksum not GSO. Please ask
your hardware guys to provide NETIF_F_HW_CSUM to avoid any more of
this unpleasantness in the future :-)

>> +           skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
>> +           skb->inner_protocol != htons(ETH_P_TEB) ||
>> +           skb_inner_mac_header(skb) - skb_transport_header(skb) !=
>> +           sizeof(struct udphdr) + sizeof(struct vxlanhdr))
>> +               return features & ~(NETIF_F_ALL_CSUM |
>> + NETIF_F_GSO_MASK);
>> +
>> +       return features;
>>  }
>>  #endif
>>
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org More majordomo info
>> at  http://vger.kernel.org/majordomo-info.html
