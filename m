From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH net 1/7] bnx2x: prevent crash when accessing PTP with
 interface down
Date: Mon, 6 Mar 2017 15:04:22 +0100
Message-ID: <1af37eff-26dd-8f3f-5f2e-ec2ab39055a3@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
 <20170303160834.4125-2-mschmidt@redhat.com>
 <BL2PR07MB23062D54948BD583E2B7D7318D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39382 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754279AbdCFOrO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 09:47:14 -0500
In-Reply-To: <BL2PR07MB23062D54948BD583E2B7D7318D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 5.3.2017 v 10:43 Mintz, Yuval napsal(a):
>> It is possible to crash the kernel by accessing a PTP device while its
>> associated bnx2x interface is down. Before the interface is brought up, the
>> timecounter is not initialized, so accessing it results in NULL dereference.
>>
>> Fix it by checking if the interface is up.
>>
>> Use -ENETDOWN as the error code when the interface is down.
>>  -EFAULT in bnx2x_ptp_adjfreq() did not seem right.
>>
>> Tested using phc_ctl get/set/adj/freq commands.
>>
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
>
> While I have no objections to the patch contents, does it even make
> sense to try adjusting frequencies on a DOWNed interface?
> Wouldn't it make more sense checking this in the calling context
> Instead?

The caller does not know. A PTP device is not necessarily associated 
with a net device.

Michal
