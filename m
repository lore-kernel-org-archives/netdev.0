From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next  04/10] ixgbe: fix link test when connected to 1Gbps
 link partner
Date: Wed, 28 Aug 2013 20:24:35 +0000
Message-ID: <87618083B2453E4A8714035B62D679924FDF9934@FMSMSX105.amr.corp.intel.com>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1377686028-30747-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <521E4148.3030402@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46358 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246Ab3H1UYi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 16:24:38 -0400
In-Reply-To: <521E4148.3030402@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Sergei Shtylyov
>[mailto:sergei.shtylyov@cogentembedded.com]
>Sent: Wednesday, August 28, 2013 11:28 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Tantilov, Emil S;
>netdev@vger.kernel.org; gospo@redhat.com;
>sassmann@redhat.com
>Subject: Re: [net-next 04/10] ixgbe: fix link test when
>connected to 1Gbps link partner
>
>Hello.
>
>On 08/28/2013 02:33 PM, Jeff Kirsher wrote:
>
>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>
>> This patch is a partial reverse of:
>> commit dfcc4615f09c33454bc553567f7c7506cae60cb9
>
>    Please also specify that commit's summary line in
>parens.

commit dfcc4615f09c33454bc553567f7c7506cae60cb9
Author: Jacob Keller <jacob.e.keller@intel.com>
Date:   Thu Nov 8 07:07:08 2012 +0000

    ixgbe: ethtool ixgbe_diag_test cleanup

>
>> Specifically forcing the laser before the link check can
>lead to
>> inconsistent results because it does not guarantee that
>the link will be
>> negotiated correctly. Such is the case when dual speed
>SFP+ module is
>> connected to a gigabit link partner.
>
>> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 26
>++++++++----------------
>>   1 file changed, 9 insertions(+), 17 deletions(-)
>
>> diff --git
>a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>> index db0dbf6..57465d8 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>> @@ -1885,11 +1885,11 @@ static void ixgbe_diag_test(struct
>net_device *netdev,
>>                               struct ethtool_test
>*eth_test, u64 *data)
>>   {
>>   	struct ixgbe_adapter *adapter = netdev_priv(netdev);
>> -	struct ixgbe_hw *hw = &adapter->hw;
>>   	bool if_running = netif_running(netdev);
>>
>>   	set_bit(__IXGBE_TESTING, &adapter->state);
>>   	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
>> +		struct ixgbe_hw *hw = &adapter->hw;
>
>    Empty line wouldn't here, after declaration. At least in
>the code above you have it.

It's probably a good idea to make it more readable. Assuming you meant adding an empty line after the declaration.

>
>>   		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
>>   			int i;
>>   			for (i = 0; i < adapter->num_vfs; i++) {
>
>WBR, Sergei

If the lack of commit description and the empty line after the *hw declaration is too big of a concern I can resubmit the patch.

Thanks,
Emil
