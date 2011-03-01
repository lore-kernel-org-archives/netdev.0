From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] cxgb{3,4}*: improve Kconfig dependencies
Date: Tue, 01 Mar 2011 09:33:05 +0000
Message-ID: <4D6CCB610200007800034422@vpn.id2.novell.com>
References: <1298950455-4497-1-git-send-email-dm@chelsio.com>
 <4D6CB26802000078000343BD@vpn.id2.novell.com>
 <4D6CB7F2.9020902@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Dimitris Michailidis" <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4D6CB7F2.9020902@chelsio.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 01.03.11 at 10:10, Dimitris Michailidis <dm@chelsio.com> wrote:
> Jan Beulich wrote:
>>>>> On 01.03.11 at 04:34, Dimitris Michailidis <dm@chelsio.com> wrote:
>>> - Remove the dependency of cxgb4 and cxgb4vf on INET.  cxgb3 really
>>>   depends on INET, keep it but add it directly to the driver's Kconfig
>>>   entry.
>>> - Make the iSCSI drivers cxgb3i and cxgb4i available in the SCSI menu
>>>   without requiring any options in the net driver menu to be enabled
>>>   first.  Add needed selects so the iSCSI drivers can build their
>>>   corresponding net drivers.
>>> - Remove CHELSIO_T*_DEPENDS.
>>>
>>> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
>>> ---
>>>  drivers/net/Kconfig               |   21 +++------------------
>>>  drivers/scsi/cxgbi/cxgb3i/Kconfig |    4 +++-
>>>  drivers/scsi/cxgbi/cxgb4i/Kconfig |    4 +++-
>>>  3 files changed, 9 insertions(+), 20 deletions(-)
>>>
>>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>>> index f4b3927..6e09d5f 100644
>>> --- a/drivers/net/Kconfig
>>> +++ b/drivers/net/Kconfig
>>> @@ -2595,14 +2595,9 @@ config CHELSIO_T1_1G
>>>  	  Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
>>>  	  are using only 10G cards say 'N' here.
>>>  
>>> -config CHELSIO_T3_DEPENDS
>>> -	tristate
>>> -	depends on PCI && INET
>>> -	default y
>>> -
>>>  config CHELSIO_T3
>>>  	tristate "Chelsio Communications T3 10Gb Ethernet support"
>>> -	depends on CHELSIO_T3_DEPENDS
>>> +	depends on PCI && INET
>> 
>> Forgot to remove INET here?
> 
> Didn't forget it, this driver has a real dependency on INET (ARP more 
> specifically).  I mentioned it also in the commit message.

Oh, sorry, must have read this too quickly.

Jan

