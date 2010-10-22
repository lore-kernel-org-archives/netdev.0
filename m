From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan
 accleration.
Date: Thu, 21 Oct 2010 17:57:39 -0700
Message-ID: <2DFD360E328B3941911E6D28B085D990129FC20F51@SJEXCHCCR01.corp.ad.broadcom.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
 <1287618974-4714-12-git-send-email-jesse@nicira.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429135@SJEXCHCCR02.corp.ad.broadcom.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429137@SJEXCHCCR02.corp.ad.broadcom.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE42913C@SJEXCHCCR02.corp.ad.broadcom.com>
 <AANLkTinudtxjGAEcc9cLjn+7Y7kqcaQXMW_5SRoNe5QU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hao Zheng" <hzheng@nicira.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Jesse Gross" <jesse@nicira.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1744 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968Ab0JVA55 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 20:57:57 -0400
In-Reply-To: <AANLkTinudtxjGAEcc9cLjn+7Y7kqcaQXMW_5SRoNe5QU@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the latest patch this one also disappeared and I do see the packets with vlan tag on the receiver's side
(For this purpose the driver was patched do not configure the stripping)

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Jesse Gross
Sent: Thursday, October 21, 2010 11:37 PM
To: Vladislav Zolotarov
Cc: David Miller; netdev@vger.kernel.org; Hao Zheng; Eilon Greenstein
Subject: Re: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan accleration.

On Thu, Oct 21, 2010 at 7:50 AM, Vladislav Zolotarov <vladz@broadcom.com> wrote:
>> > Guys, when I compiled the kernel with these patches without VLAN
>> > support (CONFIG_VLAN_8021Q is not set) and tried to send VLAN tagged
>> > frames from the remote side to the bnx2x interface the kernel
>> panicked.
>> >
>> > The stack trace got cut with the __netif_receive_skb() on top by the
>> > IPKVM and I'll have to connect a serial to get it all. But until I
>> > did that maybe somebody will have any ideas anyway...
>> >
>> > It happens regardless there is HW RX VLAN stripping enabled or not.
>>
>> When RX VLAN stripping is enabled we hit the BUG() in the
>> vlan_hwaccel_do_receive().:
>
> We hit the same BUG() both when VLAN stripping is disabled.

This one surprises me because that function shouldn't get called at
all when VLAN stripping is disabled.  Are you sure that it is
disabled?  From my reading of the bnx2x driver it seems like it is
always enabled.
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


