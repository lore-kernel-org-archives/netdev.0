From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 09:39:47 +0100
Message-ID: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36620 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbdJKJUM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 05:20:12 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am having an issue with af_packet.c

It fails to transmit any TSO frame submitted via raw socket + vnet 
headers. An identical frame is considered valid for tap.

The frames are generated out of legit linux skbufs (in UML) and vnet 
headers work for checksumming on raw, so I should have the raw 
initialization right.

The header is supposedly parsed correctly and the newly formed skbuf is 
sent to the device transmit routine (or enqueued) . I have debugged it 
as far as it reaching the following line in packet_snd() (line 2592 in 
4.13):

err = po->xmit(skb);

This returns NET_XMIT_DROP for any TSO capable device I tested. They 
dislike the frame. Same frame is accepted by tap. I have went through 
the header parsing and skb allocation code in both af_packet and tap 
several times and I do not see any material difference (except the new 
zerocopy stuff). So, frankly, I am stuck.

Can someone help me to debug this. I do not see an easy way to debug it, 
but this is not a part of the kernel I am familiar with. Is there a 
suitable helper function to try to segment the frame and see exactly 
what is wrong with it?

Cc-ing DaveM as this has no specific maintainer so it falls under his 
umbrella remit.

-- 
Anton R. Ivanov

Cambridge Greys Limited, England and Wales company No 10273661
http://www.cambridgegreys.com/	
