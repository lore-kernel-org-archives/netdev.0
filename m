From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next  04/10] ixgbe: fix link test when connected to 1Gbps
 link partner
Date: Thu, 29 Aug 2013 00:38:18 +0400
Message-ID: <521E5FBA.9040400@cogentembedded.com>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com> <1377686028-30747-5-git-send-email-jeffrey.t.kirsher@intel.com> <521E4148.3030402@cogentembedded.com> <87618083B2453E4A8714035B62D679924FDF9934@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:38891 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913Ab3H1UiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 16:38:19 -0400
Received: by mail-la0-f49.google.com with SMTP id ev20so5081125lab.8
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 13:38:18 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D679924FDF9934@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2013 12:24 AM, Tantilov, Emil S wrote:

>>> From: Emil Tantilov <emil.s.tantilov@intel.com>

>>> This patch is a partial reverse of:
>>> commit dfcc4615f09c33454bc553567f7c7506cae60cb9

>>     Please also specify that commit's summary line in
>> parens.

> commit dfcc4615f09c33454bc553567f7c7506cae60cb9
> Author: Jacob Keller <jacob.e.keller@intel.com>
> Date:   Thu Nov 8 07:07:08 2012 +0000

>      ixgbe: ethtool ixgbe_diag_test cleanup

>>> Specifically forcing the laser before the link check can
>> lead to
>>> inconsistent results because it does not guarantee that
>> the link will be
>>> negotiated correctly. Such is the case when dual speed
>> SFP+ module is
>>> connected to a gigabit link partner.

>>> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>    drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 26
>>> ++++++++----------------
>>>    1 file changed, 9 insertions(+), 17 deletions(-)

>>> diff --git
>>> a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>>> index db0dbf6..57465d8 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>>> @@ -1885,11 +1885,11 @@ static void ixgbe_diag_test(struct
>> net_device *netdev,
>>>                                struct ethtool_test
>> *eth_test, u64 *data)
>>>    {
>>>    	struct ixgbe_adapter *adapter = netdev_priv(netdev);
>>> -	struct ixgbe_hw *hw = &adapter->hw;
>>>    	bool if_running = netif_running(netdev);
>>>
>>>    	set_bit(__IXGBE_TESTING, &adapter->state);
>>>    	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
>>> +		struct ixgbe_hw *hw = &adapter->hw;
>>
>>     Empty line wouldn't here, after declaration. At least in

    Missed the verb "hurt" before "here".

>> the code above you have it.

> It's probably a good idea to make it more readable. Assuming you meant adding an empty line after the declaration.

    Yes.

>>
>>>    		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
>>>    			int i;
>>>    			for (i = 0; i < adapter->num_vfs; i++) {
>>
>> WBR, Sergei

> If the lack of commit description and the empty line after the *hw declaration is too big of a concern I can resubmit the patch.

    The earlier is certainly a requirement (coming originally from Linus). 
It's the only way to uniquely identify the commit and it's the only way to 
easily know what the commit was about without a git tree or with 'cgit' 
currently used by http://git.kernel.org (it doesn't follow the commit SHA1 as 
the 'gitweb' used to do).

> Thanks,
> Emil

WBR, Sergei
