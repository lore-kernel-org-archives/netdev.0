From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH v2] i40e/i40evf: Limit TSO to 7 descriptors for
 payload instead of 8 per packet
Date: Thu, 31 Mar 2016 15:09:13 -0700
Message-ID: <CAKgT0UeBoTEkPrvuzawh8mxZHcaFx8z-AFSG=t_=K1LmG2mthg@mail.gmail.com>
References: <20160330231116.12643.59554.stgit@localhost.localdomain>
	<20160331150438.00005617@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35172 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757259AbcCaWJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 18:09:14 -0400
Received: by mail-io0-f171.google.com with SMTP id g185so131982338ioa.2
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 15:09:13 -0700 (PDT)
In-Reply-To: <20160331150438.00005617@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 3:04 PM, Jesse Brandeburg
<jesse.brandeburg@intel.com> wrote:
> On Wed, 30 Mar 2016 16:15:37 -0700
> Alexander Duyck <aduyck@mirantis.com> wrote:
>
>> This patch addresses a bug introduced based on my interpretation of the
>> XL710 datasheet.  Specifically section 8.4.1 states that "A single transmit
>> packet may span up to 8 buffers (up to 8 data descriptors per packet
>> including both the header and payload buffers)."  It then later goes on to
>> say that each segment for a TSO obeys the previous rule, however it then
>> refers to TSO header and the segment payload buffers.
>>
>> I believe the actual limit for fragments with TSO and a skbuff that has
>> payload data in the header portion of the buffer is actually only 7
>> fragments as the skb->data portion counts as 2 buffers, one for the TSO
>> header, and one for a segment payload buffer.
>>
>> Fixes: 2d37490b82af ("i40e/i40evf: Rewrite logic for 8 descriptor per packet check")
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
>>
>> v2: I realized that I overlooked the check in the inline function and as a
>>     result we were still allowing for cases where 8 descriptors were being
>>     used per packet and this would result in 9 DMA buffers.  I updated the
>>     code so that we only allow 8 in the case of a single send, otherwise we
>>     go into the function that walks the frags to verify each block.
>>
>> I have tested this using rds-stress and it seems to run traffic without
>> throwing any errors.
>
> Looking like it is working for me too with at least the PF.

I was testing PF <-> VF in my environment so I think I ended up
covering both in my test at least.

- Alex
