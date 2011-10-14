From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot device
Date: Fri, 14 Oct 2011 13:17:58 -0700
Message-ID: <4E9898F6.6000302@intel.com>
References: <1318563481-19631-1-git-send-email-mchan@broadcom.com> <4E9855EC.1020509@hp.com> <C27F8246C663564A84BB7AB34397724266D2018303@IRVEXCHCCR01.corp.ad.broadcom.com> <4E985DE8.3090308@hp.com> <C27F8246C663564A84BB7AB34397724266D2018306@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: 'Rick Jones' <rick.jones2@hp.com>,
	"'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47551 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933441Ab1JNUR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 16:17:59 -0400
In-Reply-To: <C27F8246C663564A84BB7AB34397724266D2018306@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2011 9:15 AM, Michael Chan wrote:
> Rick Jones wrote:
> 
>> On 10/14/2011 08:53 AM, Michael Chan wrote:
>>> Rick Jones wrote:
>>>
>>>> Is this perhaps saying that a bnx2x-driven device being used for
>>>> FCoE or iSCSI boot must not permit *any* run-time configuration
>>>> change which leads to a NIC reset?
>>>>
>>>
>>> That is right.  Unless you have a multipath configuration with
>> multiple
>>> ports, then you can reset one port at a time.
>>
>> So, should there also be a "cnic_boot_device" check in many of the
>> "capital letter" ethtool paths?
>>
> 
> If the user is doing ethtool configuration changes or device shutdown,
> it is more obvious what the consequence will be.  The user may also be
> careful to do it on a multipath setup.
> 
> The reset caused by the auto turn-off of LRO when you enable
> ip_forward or bridging will not be obvious to the user.  In addition,
> all devices with LRO turned on will be reset at the same time so even
> multipath will not survive.
>

But after the reset the device should login and SCSI layer should
handle retries. So I don't see why this is a problem. Why do we
need to handle this any different from any other link events?

.John
