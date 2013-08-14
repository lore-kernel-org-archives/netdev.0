From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCHv2 net-next 0/6] 6lowpan: uncompress of addresses fix
Date: Wed, 14 Aug 2013 14:41:19 +0200
Message-ID: <20130814124117.GA4303@x61s.8.8.8.8>
References: <1376478108-3539-1-git-send-email-alex.aring@gmail.com>
 <520B68C4.7030602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:36429 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932188Ab3HNMhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 08:37:31 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so4713253ead.21
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 05:37:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <520B68C4.7030602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On Wed, Aug 14, 2013 at 03:23:48PM +0400, Alexander Smirnov wrote:
> On 08/14/2013 03:01 PM, Alexander Aring wrote:
> >The current implementation to uncompress addresses in a 6lowpan header
> >is completely broken.
> >
> >This patch series fixes the parsing of addresses in a 6lowpan header.
> >It contains a major rewrite of the uncompress address function to parse
> >the address in a correct way.
> >
> 
> Could you please describe in a few words how have you tested the changes?
> 

I test this with a ravenusbstick and the jackdaw firmware.
This is a usb stick with a contiki stack which offers a ipv6 interface
under linux. It still uses the 6LoWPAN contiki stack.

On the other side I have a beaglebone device with the current net-next
6LoWPAN stack.

I add several addresses to this linux device to catch all cases (except
short address) in the uncompression function.
With a ping6 $ADDRESS and wireshark on the usb stick I see the
outcomming 6lowpan packets. If I get a correct reply with the used
address it seems that the uncompression works.

I am thinking to implement some test cases to test all uncompression of
all address-cases. This patch series was tested manually.



A wireshark on the beaglebone doesn't work at the moment. I get a
nullpointer dereference in the 6LoWPAN stack. I suppose this is why the
6LoWPAN Stack copies sk_buffs and free the old one. This is a wrong
behaviour because the caller of a function has the old sk_buff which is
freed.

I need some time to drop the skb_clone functions.... and then I will
check wireshark.

If wireshark works I don't see the 6LoWPAN Header anyway, but I can see
if the ipv6 header is reconstructed correctly.

> Small cosmetic hint: lowpan_raw_dump_inline() already has an
> argument to print debug message, so there is no need to add extra
> pr_debug calls before it to print static text.
> 
ok, I will change it.

Regards
Alex
