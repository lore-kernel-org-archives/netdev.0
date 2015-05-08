From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH v1 net-next 2/2] igb: support SIOCSMIIREG
Date: Fri, 08 May 2015 12:57:48 -0400
Message-ID: <554CEB0C.40308@cumulusnetworks.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com> <1429302240-654-2-git-send-email-jtoppins@cumulusnetworks.com> <554BA646.1060000@gmail.com> <93C443E7-4209-45A3-A54F-949A4ECDD508@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Alan Liebthal <alanl@cumulusnetworks.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:32811 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081AbbEHQ5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 12:57:51 -0400
Received: by qgdy78 with SMTP id y78so39378256qgd.0
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 09:57:50 -0700 (PDT)
In-Reply-To: <93C443E7-4209-45A3-A54F-949A4ECDD508@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/7/15 4:46 PM, Rustad, Mark D wrote:
>> On May 7, 2015, at 10:52 AM, Alexander Duyck <alexander.duyck@gmail.com> wrote:
>>
>>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
>>> index 720b785..1071a71 100644
>>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>>> @@ -7141,6 +7141,11 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
>>>   			return -EIO;
>>>   		break;
>>>   	case SIOCSMIIREG:
>>> +		adapter->hw.phy.addr = data->phy_id;
>>> +		if (igb_write_phy_reg(&adapter->hw, data->reg_num & 0x1F,
>>> +				      data->val_in))
>>> +			return -EIO;
>>> +		break;
>>>   	default:
>>>   		return -EOPNOTSUPP;
>>>   	}
>>
>> How and why is this being used?  From what I can tell it looks like it is an easy way to break any of the existing interfaces if it is misused since all you would need to do is specify a phy address that doesn't match the existing PHY in the system and then you would likely lose link, or possibly mess up the configuration on the system requiring.
>>
>> I suspect this is a back door for some piece of user space code that is being given far more permission than it should be.
>
> I don't know about a back door, but the real problem is that it has a
> side-effect of changing the saved value of the phy addr. That is clearly
> a problem and can't be allowed.

This patch was worse before... it had changes in SIOGMIIREG that had 
similar side-effects, missed this one.

Checking with some of the platform people here this patch can be 
dropped. We don't use it as a backdoor of any kind it was mainly used 
for debugging/guess-what-the-phy-addr-was when we originally got the boards.
>
> For the phylib stuff to really work as intended, the igb_write_phy_reg
> really should take the phy address as a parameter instead of getting
> the value from the structure itself. Or a new function should be
> defined that has that interface.
>
> --
> Mark Rustad, Networking Division, Intel Corporation
>
