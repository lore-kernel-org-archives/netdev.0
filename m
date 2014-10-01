From: Pramod Gurav <pramod.gurav@smartplayin.com>
Subject: Re: [PATCH] ssb: Fix Sparse error in main
Date: Wed, 01 Oct 2014 13:09:31 +0530
Message-ID: <542BAFB3.6030207@smartplayin.com>
References: <1412147196-7466-1-git-send-email-pramod.gurav@smartplayin.com> <1412148544.21730.36.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Michael Buesch <m@bues.ch>,
	netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412148544.21730.36.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 October 2014 12:59 PM, Paul Bolle wrote:
> On Wed, 2014-10-01 at 12:36 +0530, Pramod Gurav wrote:
>> This change fixes below sparse error:
>>
>> drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
>> was not declared. Should it be static?
>>
>> Cc: Michael Buesch <m@bues.ch>
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Pramod Gurav <pramod.gurav@smartplayin.com>
>> ---
>>  drivers/ssb/ssb_private.h |    1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/ssb/ssb_private.h b/drivers/ssb/ssb_private.h
>> index eb507a5..86bbbe3 100644
>> --- a/drivers/ssb/ssb_private.h
>> +++ b/drivers/ssb/ssb_private.h
>> @@ -193,6 +193,7 @@ extern struct ssb_bus *ssb_pci_dev_to_bus(struct pci_dev *pdev);
>>  int ssb_for_each_bus_call(unsigned long data,
>>  			  int (*func)(struct ssb_bus *bus, unsigned long data));
>>  extern struct ssb_bus *ssb_pcmcia_dev_to_bus(struct pcmcia_device *pdev);
>> +struct ssb_bus *ssb_sdio_func_to_bus(struct sdio_func *func);
>>  
>>  struct ssb_freeze_context {
>>  	/* Pointer to the bus */
> 
> To me this looked like an odd way to silence that warning. So I dug a
> bit further.
> 
> ssb_sdio_func_to_bus() was added in commit 24ea602e183c ("ssb: Implement
> SDIO host bus support"). So it was added in release v2.6.32. I found no
> evidence this function was ever used. Can't it be removed?
> 
Thanks Paul for review. Initially I too had greped for this function in
kernel and found noone using it. But I thought this function might be
useful in future. About removing it, may be original author can tell.
> 
> Paul Bolle
> 
