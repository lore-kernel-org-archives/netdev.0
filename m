From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan accleration.
Date: Thu, 21 Oct 2010 14:34:34 -0700
Message-ID: <AANLkTik1HsFu_4hjRJ2ynH4a-O5VFDNRWD-HQxwtkmJT@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-12-git-send-email-jesse@nicira.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429135@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429137@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hao Zheng <hzheng@nicira.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41766 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501Ab0JUVef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:34:35 -0400
Received: by wyf28 with SMTP id 28so77871wyf.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:34:34 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429137@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 7:02 AM, Vladislav Zolotarov <vladz@broadcom.com> wrote:
>> Guys, when I compiled the kernel with these patches without VLAN
>> support (CONFIG_VLAN_8021Q is not set) and tried to send VLAN tagged
>> frames from the remote side to the bnx2x interface the kernel panicked.
>>
>> The stack trace got cut with the __netif_receive_skb() on top by the
>> IPKVM and I'll have to connect a serial to get it all. But until I
>> did that maybe somebody will have any ideas anyway...
>>
>> It happens regardless there is HW RX VLAN stripping enabled or not.
>
> When RX VLAN stripping is enabled we hit the BUG() in the
> vlan_hwaccel_do_receive().

Thanks, this is just a stupid mistake - I didn't update the
non-CONFIG_VLAN_8021Q version when I changed the semantics of that
function.  I've sent out a patch to fix it.
