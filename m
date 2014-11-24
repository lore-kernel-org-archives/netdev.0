From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4: Fix EEH recovery failure
Date: Tue, 25 Nov 2014 08:42:42 +1100
Message-ID: <20141124214242.GA5352@shangw>
References: <1416653807-4859-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <5472099B.5070105@mellanox.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	yishaih@mellanox.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:54655 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbaKXVmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:42:50 -0500
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 25 Nov 2014 03:12:47 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id CB333125804B
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 03:12:56 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAOLisag62455822
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 03:14:54 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAOLgi2x009409
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 03:12:44 +0530
Content-Disposition: inline
In-Reply-To: <5472099B.5070105@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2014 at 06:21:47PM +0200, Amir Vadai wrote:
>On 11/22/2014 12:56 PM, Gavin Shan wrote:
>> The patch fixes couple of EEH recovery failures on PPC PowerNV
>> platform:
>> 
>>    * Release reserved memory regions in mlx4_pci_err_detected().
>>      Otherwise, __mlx4_init_one() fails because of reserving
>>      same memory regions recursively.
>>    * Disable PCI device in mlx4_pci_err_detected(). Otherwise,
>>      pci_enable_device() in __mlx4_init_one() doesn't enable
>>      the PCI device because it's already in enabled state indicated
>>      by struct pci_dev::enable_cnt.
>>    * Don't clear struct mlx4_priv instance in mlx4_pci_err_detected().
>>      Otherwise, __mlx4_init_one() runs into kernel crash because
>>      of dereferencing to NULL pointer.
>> 
>> With the patch applied, EEH recovery for mlx4 adapter succeeds on PPC
>> PowerNV platform.
>> 
>>    # lspci
>>    0003:0f:00.0 Network controller: Mellanox Technologies \
>>    MT27500 Family [ConnectX-3]
>> 
>> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>
>Hi Gavin,
>
>Yishai (added to the CC) is few days before sending a patchset to fix
>the reset flow and inside it there is a fix to EEH recovery.
>I would be happy if you could wait for the whole reset flow fix by Yishai.
>

Yes, It's not urgent and I can wait. Thanks for the info.

>If you'd like, I can send you the patchset to try. Currently it is under
>review inside Mellanox before being sent to the mailing list.
>

It would be nice to send me the patchset for me to have a try.

Thanks,
Gavin

>Thanks,
>Amir
>
>
>
>
