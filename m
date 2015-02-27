From: nick <xerofoify@gmail.com>
Subject: Re: i40e: crash on NMI by continuous module reload
Date: Fri, 27 Feb 2015 09:44:24 -0500
Message-ID: <54F082C8.8040407@gmail.com>
References: <54F07630.1010802@kpanic.de> <54F078DF.5020100@gmail.com>
	<54F07C29.8010805@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Stefan Assmann <sassmann@kpanic.de>, netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <54F07C29.8010805@kpanic.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On 2015-02-27 09:16 AM, Stefan Assmann wrote:
> On 27.02.2015 15:02, nick wrote:
> 
> [...]
> 
>>>     i40e: Fix a bug where Rx would stop after some time
>>> [...]
>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>>> index f7464e8..ff6d94d 100644
>>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>>> [...]
>>> @@ -9169,6 +9178,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>>>  	if (err)
>>>  		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n", err);
>>>
>>> +	msleep(75);
>>> +	err = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
>>> +	if (err) {
>>> +		dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
>>> +			 pf->hw.aq.asq_last_status);
>>> +	}
>>> +
>>>  	/* The main driver is (mostly) up and happy. We need to set this state
>>>  	 * before setting up the misc vector or we get a race and the vector
>>>  	 * ends up disabled forever.
>>>
>>> With this hunk removed the driver successfully unloaded/reloaded a
>>> couple of hundred times. Would it be safe to just remove this hunk?
>>> I haven't seen any negative effects by removing this yet.
>>>
>>>   Stefan
>>>
>> Stefan,
>> I wouldn't remove them yet as this does look like a valid idea to check to see if the link is 
>> restarting successfully. On the other hand can you try removing the msleep line as this one is
>> most likely causing the issue due to sleeping for some long in a probe function is generally a
>> bad idea.
>> Thanks,
>> Nick
> 
> Thanks Nick for the quick reply. I tested removing the msleep but that
> didn't make a difference. You actually need to remove the complete hunk
> to get a stable driver reload.
> 
>   Stefan
> 
Stefan,
Basically there are a few things that could be going wrong
1. You are getting a error return for the function,i40e_aq_set_link_restart_an
2. You are trying to re able the device again when not needed
3. You are sending a NULL value to a field for command arguments that takes a 0 and not NULL
to take no arguments
Nick 

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
