From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH] igb: fix misinterpreted return value of pci_enable_msix
Date: Tue, 24 Nov 2009 11:51:24 +0100
Message-ID: <4B0BBAAC.8050606@redhat.com>
References: <4B0BB5FE.2000907@redhat.com> <20091124104049.GB21600@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@redhat.com>,
	alexander.h.duyck@intel.com, davem@davemloft.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932204AbZKXKvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 05:51:37 -0500
In-Reply-To: <20091124104049.GB21600@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.11.2009 11:40, Florian Westphal wrote:
> Stefan Assmann <sassmann@redhat.com> wrote:
>> From: Stefan Assmann <sassmann@redhat.com>
>>
>> In the igb driver a return value of 0 of function pci_enable_msix is
>> interpreted as an error case. The correct behaviour is to check < 0 for error
>> values.
>>
>> Signed-off-by: Stefan Assmann <sassmann@redhat.com>
>> ---
>>  drivers/net/igb/igb_main.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
>> index bb1a6ee..745481d 100644
>> --- a/drivers/net/igb/igb_main.c
>> +++ b/drivers/net/igb/igb_main.c
>> @@ -694,7 +694,7 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
>>  	err = pci_enable_msix(adapter->pdev,
>>  			      adapter->msix_entries,
>>  			      numvecs);
>> -	if (err == 0)
>> +	if (err < 0)
>>  		goto out;
>>
> 
> The existing code looks correct to me:
> 
>       if (err == 0)
>             goto out;
> 
>       igb_reset_interrupt_capability(adapter);
> 
>       /* If we can't do MSI-X, try MSI * */
> msi_only:
> 
> 
> so the "goto out" appears to be the "success" case.

Hi Florian,

thanks for pointing this out. I've jumped to conclusions too fast.
There's a problem with igb MSI-X in RHEL5 in the kdump case and this
fixed it for me. But you're right, it's not the proper solution. I'll
report back when I have more information.

  Stefan

--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera
