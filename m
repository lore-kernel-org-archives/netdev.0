From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/3] A few minor clean-ups to eth_type_trans
Date: Thu, 30 Apr 2015 16:11:43 -0700
Message-ID: <5542B6AF.9010602@gmail.com>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22> <20150430223510.GA13111@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35964 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbbD3XLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 19:11:46 -0400
Received: by pdea3 with SMTP id a3so74977511pde.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 16:11:45 -0700 (PDT)
In-Reply-To: <20150430223510.GA13111@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 03:35 PM, Alexei Starovoitov wrote:
> On Thu, Apr 30, 2015 at 02:53:42PM -0700, Alexander Duyck wrote:
>> This series addresses a few minor issues I found in eth_type_trans that
>> that allow us to gain back something like 3 or more cycles per packet.
>>
>> The first change is to drop the byte swap since it isn't necessary.  On x86
>> we could just check the first byte and compare that against the upper 8
>> bits of the Ethertype to determine if we are dealing with a size value or
>> not.
>>
>> The second makes it so that the value we read in to test for multicast can
>> be used for the address comparison.  This allows us to avoid a second read
>> of the destination address.
>>
>> The final change is to avoid some unneeded instructions in computing the
>> Ethernet header pointer.  When we start the call the Ethernet header is at
>> skb->data, so we just use that rather than computing mac_header, and then
>> adding that back to skb->head.
> Great stuff! Excellent optimizations.
>
> Only the comment 'ETH_P_802_3_MIN is aligned to 512' through me off.
> It's divisible by 256 that matters.

Yeah, it is 0x0600 hex so we can ignore the lower 8 bits, or in the case 
of little-endian systems the upper 8 bits.  I think when I had 
originally written the patch I was using a mask of 0xFE00, but then I 
realized that all the compiler cared about is knowing which byte it is 
supposed to compare against.

- Alex
