From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] iwlwifi: use pci_dev->revision, again
Date: Fri, 24 Jun 2011 18:37:55 +0400
Message-ID: <4E04A143.1090204@mvista.com>
References: <201106231841.40691.sshtylyov@ru.mvista.com>	 <1308841365.13397.274.camel@wwguy-huron>  <4E046A9F.9020909@mvista.com> <1308924515.19001.2.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: wwguy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308924515.19001.2.camel@wwguy-ubuntu>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

wwguy wrote:

>>>> Commit ff938e43d39e926de74b32a3656c190f979ab642 (net: use pci_dev->revision,
>>>> again) already converted this driver to using the 'revision' field of 'struct
>>>> pci_dev' but commit c2974a1d18832a9fffb2eb389c3878f5c4ed92f1 (iwlagn: remove
>>>> rev_id) later reverted that change for no reason. Now restore the change...
>>>> Signed-off-by: Sergei Shtylyov<sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
>>>> ---
>>>> The patch is against the recent Linus' tree.
>>>>   drivers/net/wireless/iwlwifi/iwl-agn.c |    5 ++---
>>>>   1 file changed, 2 insertions(+), 3 deletions(-)
>>>> Index: linux-2.6/drivers/net/wireless/iwlwifi/iwl-agn.c
>>>> ===================================================================
>>>> --- linux-2.6.orig/drivers/net/wireless/iwlwifi/iwl-agn.c
>>>> +++ linux-2.6/drivers/net/wireless/iwlwifi/iwl-agn.c
>>>> @@ -3275,10 +3275,9 @@ struct ieee80211_ops iwlagn_hw_ops = {
>>>>
>>>>   static u32 iwl_hw_detect(struct iwl_priv *priv)
>>>>   {
>>>> -	u8 rev_id;
>>>> +	IWL_DEBUG_INFO(priv, "HW Revision ID = 0x%X\n",
>>>> +		       priv->pci_dev->revision);
>>>>
>>>> -	pci_read_config_byte(priv->pci_dev, PCI_REVISION_ID,&rev_id);
>>>> -	IWL_DEBUG_INFO(priv, "HW Revision ID = 0x%X\n", rev_id);
>>>>   	return iwl_read32(priv, CSR_HW_REV);
>>>>   }

>>> hmm, I believe it is merge sequence issue, the IWL_DEBUG_INFO line has
>>> benn remove all together in later patch. the information is being log in
>>> the calling function, no need to log in "iwl_hw_detect"

>>     Hm, you probably mean this patch in the iwlwifi-2.6.git (of which I wasn't 
>> aware):

>> author	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>	
>> 	Tue, 31 May 2011 06:58:18 +0000 (09:58 +0300)
>> committer	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>	
>> 	Sat, 18 Jun 2011 15:18:01 +0000 (08:18 -0700)
>> commit	85aed7c48113dfcdc913008481c46346af0db69e
>> tree	75831a2ec540039470c295a81c2059a24a4531f5
>> parent	19707bac16129ccebc398dbff9d2b44b17b24fea

>> iwlagn: don't read the PCI_REVISION_ID from iwl-agn.c

>> The PCI_REVISION_ID is read and printed in iwl_pci_probe anyway using pr_info

>> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Signed-off-by: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

>>     Since iwl_pci_probe() still reads the PCI config. register, my patch 
>> should be recast to modify iwl-pci.c instead...

> I don't believe this patch is needed since the "log" statement is move
> to outside the function.

    That's what I'm talking about -- it's not needed in its current form, but I 
will redo the patch to modify iwl-pci,c where iwl_pci_probe() still reads 
PCI_REVISION_ID.

> Thanks
> Wey

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
