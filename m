From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] net/openvswitch: Remove the skb encapsulation mark after decapsulation
Date: Wed, 22 Jan 2014 19:23:16 +0200
Message-ID: <CAJZOPZ+oRD=76JUELo51yZTTvjnc=4HYy0EPWtR1HH1CY870cA@mail.gmail.com>
References: <1390403705-28690-1-git-send-email-ogerlitz@mellanox.com>
	<CAEP_g=9_8aPyve-obKCLo9ByFPvSNEtNBpaUKCw7X8Tcc3U1yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:45039 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbaAVRXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 12:23:17 -0500
Received: by mail-pa0-f49.google.com with SMTP id hz1so663064pad.36
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 09:23:17 -0800 (PST)
In-Reply-To: <CAEP_g=9_8aPyve-obKCLo9ByFPvSNEtNBpaUKCw7X8Tcc3U1yA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 7:02 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Wed, Jan 22, 2014 at 7:15 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> We must unset the skb encapsulation mark before injecting the
>> decapsulated packet into ovs for the rest of its journey.
>>
>> This follows the practice set by 0afb166 "vxlan: Add capability of Rx
>> checksum offload for inner packet" and the overall idea behind the
>> skb encapsulation field.
>>
>> Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
>> Cc: Pravin B Shelar <pshelar@nicira.com>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>
> This should be in the common decapsulation code. It doesn't make sense
> to do this here when we set the layer pointers, encap bit, etc. in
> common code on transmit.

well that's a bit problematic, since the code in the vxlan driver vxlan_rcv()
which has the potential to be common refers to vxlan->dev-> which is
irrelevant for ovs, thoughts?
