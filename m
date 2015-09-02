From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next 05/19] ixgbe: Add support for UDP-encapsulated tx
 checksum offload
Date: Wed, 2 Sep 2015 16:21:16 -0700
Message-ID: <CALx6S36-CAWVme16XOT6Gj5HnkFCbkQgsSBPVjXbzWbRLnqYuw@mail.gmail.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1441156443-33381-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<CALx6S34-mUvQyUQNcVC+o+NeUxWEsCG2GS=Eq++eGqoh=kv8kg@mail.gmail.com>
	<F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33906 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbbIBXVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 19:21:17 -0400
Received: by igcpb10 with SMTP id pb10so1903016igc.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 16:21:16 -0700 (PDT)
In-Reply-To: <F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 2, 2015 at 9:46 AM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>> On Sep 1, 2015, at 8:17 PM, Tom Herbert <tom@herbertland.com> wrote:
>>
>> I suspect this is not UDP-encapsulation specific, will it work with
>> TCP/IP/IP, TCP/IP/GRE etc.?
>
Mark, another question in this area of code. Looking at ixgbe_tx_csum,
I'm wondering what happens with those default cases for the switch
statements. If those are hit for whatever reason does that mean the
checksum is never resolved? It seems like if the device couldn't
handle these cases then skb_checksum_help should be called to set the
checksum. In particular I am wondering what happens in the case that a
TCP or UDP packet is sent in IPv6 with an extension header present (so
default is taken in switch (l4_hdr)). Would the checksum be properly
set in this case?

Thanks,
Tom

> It could do more, but this is what has been tested up to this point.
>
>> Isn't there anyway the ixgbe could just be made to NETIF_HW_CSUM? That
>> would be so much more straightforward and support nearly all use cases
>> without needing to jump through all these hoops.
>
> Well, the description says:
>
>  ---
> Note: NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM + NETIF_F_IPV6_CSUM.
> It means that device can fill TCP/UDP-like checksum anywhere in the packets
> whatever headers there might be.
>  ---
>
> The device can't do whatever, wherever. There is always a limit to the offset to the inner headers that can be handled, for instance.
>
> --
> Mark Rustad, Networking Division, Intel Corporation
>
