From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: tg3 issue with tcp checksums and vlan packets
Date: Tue, 16 Sep 2014 14:45:57 -0400
Message-ID: <54188565.7040600@gmail.com>
References: <541868A9.7080407@gmail.com> <1410886475.7520.73.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:52015 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594AbaIPSqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 14:46:00 -0400
Received: by mail-qc0-f169.google.com with SMTP id r5so447439qcx.28
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 11:45:59 -0700 (PDT)
In-Reply-To: <1410886475.7520.73.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2014 12:54 PM, Michael Chan wrote:
> On Tue, 2014-09-16 at 12:43 -0400, Vlad Yasevich wrote: 
>> Prashant and Michael
>>
>> I am seeing a strange issue with tg3 driver when I try to pass to it tcp packets
>> that have partial checksums and inline (non-accelerated) vlan header.
>>
> 
> Are you disabling NETIF_F_HW_VLAN_CTAG_TX?  I believe TX checksum and
> TSO won't work.  We need to add some code to disable both when VLAN
> acceleration is disabled.
> 
> 

No, in this case, I am simply creating an 802.1ad vlan on top.  Since
tg3 doesn't provide ETIF_F_HW_VLAN_STAG_TX, we follow the non-accelerated
path.

Currently the driver doesn't appear to be offer ability to disable vlan acceleration.
However, if any software devices on top of the card do not support it for some reason,
then the issue would be seen as well.

-vlad
