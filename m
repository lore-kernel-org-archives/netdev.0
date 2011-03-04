From: Prasanna Panchamukhi <ppanchamukhi@riverbed.com>
Subject: Re: [PATCH] e1000: power off PHY after reset when interface is down
Date: Fri, 04 Mar 2011 14:41:44 -0800
Message-ID: <4D716AA8.4060508@riverbed.com>
References: <1298424313-9840-1-git-send-email-prasanna.panchamukhi@riverbed.com>	<1298505765.25453.17.camel@jtkirshe-linux> <AANLkTim-T99r+npYWCLH8ry+hbtCNBOM4WUev8soaoM6@mail.gmail.com> <4D71298F.6090009@riverbed.com>
Reply-To: prasanna.panchamukhi@riverbed.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eng.riverbed.com ([208.70.196.44]:28865 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932520Ab1CDWmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 17:42:06 -0500
In-Reply-To: <4D71298F.6090009@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2011 10:03 AM, Prasanna Panchamukhi wrote:
> On 03/04/2011 12:19 AM, Jeff Kirsher wrote:
>> On Wed, Feb 23, 2011 at 16:02, Jeff Kirsher<jeffrey.t.kirsher@intel.com>   wrote:
>>> On Tue, 2011-02-22 at 17:25 -0800, prasanna.panchamukhi@riverbed.com
>>> wrote:
>>>> From: Prasanna S. Panchamukhi<prasanna.panchamukhi@riverbed.com>
>>>>
>>>> Some Phys supported by the e1000 driver do not remain powered off
>>>> across
>>>> a reset of the device when the interface is down, e.g. on 82546.
>>>> This patch powers down (only when WoL is disabled) the PHY after reset
>>>> if
>>>> the interface is down and ethtool diagnostics are not currently
>>>> running.
>>>>
>>>> Similar problem was see on 82571 controller and was fixed in e1000e
>>>> driver
>>>> by Bruce Allan.
>>>> Please refer commit 31dbe5b4ac6fca72dec946e4d0fa7f0913f1d9b1 for
>>>> details.
>>>>
>>>> Signed-off-by: Prasanna S. Panchamukhi
>>>> <prasanna.panchamukhi@riverbed.com>
>>>> ---
>>>>    drivers/net/e1000/e1000_ethtool.c |   27 +++++++++++++++++++--------
>>>>    drivers/net/e1000/e1000_main.c    |    7 +++++++
>>>>    2 files changed, 26 insertions(+), 8 deletions(-)
>>> Thanks Prasanna!  I have added the patch to my queue of e1000 patches.
>>>
>> Prasanna-
>> Here is what we found during validating your patch:
>>
>> The behavior of 82546 device(s) seems to be identical with/without this patch
>> applied. 82546GB (LOM), dev_id 1079 powers down (with wol disabled) after
>> ifdown, but powers back up after approx. 10 seconds. 82546EB (NIC), dev_id
>> 1010 powers down (with wol disabled) after ifdown. Both of the above
>> behaviors are the same with and without the patch applied. Also, if this patch
>> DID work as expected, it should print a message after a reset, such as "Cannot
>> restart autonegotiation: Resource temporarily unavailable", which would mirror
>> the behavior of e1000e.
>>
> Hi Jeff,
>
> Below is the test case we run verify this fix:
>
> $ ethtool -s eth0 wol d
> $ ifconfig eth0 up
> $ mii-tool eth0
> eth0: negotiated 100baseTx-FD, link ok
> $ ifconfig eth0 down
> $ mii-tool eth0
> eth0: no link
> $ ethtool -s eth0 autoneg on  (doesn't really matter what we do here)
> $ mii-tool eth0
> eth0: negotiated 100baseTx-FD, link ok (this should be: eth0: no link)
>
> I will re-run the test&   check if does not fix this.
Hi Jeff,

I re-verified it & confirm that, this patch fixes the problem.
Please let me know if you have any issues.

Thanks
Prasanna

> Thanks
> Prasanna
>
>
>

