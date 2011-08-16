From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] bnx2x: suppress repeated error messages about Max BW
Date: Tue, 16 Aug 2011 13:38:40 +0200
Message-ID: <4E4A56C0.4030009@redhat.com>
References: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com> <1313405680.31417.6.camel@lb-tlvb-eilong.il.broadcom.com> <4E490A1E.3060209@redhat.com> <1313411585.31417.35.camel@lb-tlvb-eilong.il.broadcom.com> <4E493798.7010405@redhat.com> <1313434042.30399.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465Ab1HPLio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 07:38:44 -0400
In-Reply-To: <1313434042.30399.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2011 08:47 PM, Eilon Greenstein wrote:
> On Mon, 2011-08-15 at 08:13 -0700, Michal Schmidt wrote:
>> A tester reported getting only these 4 messages with the patch applied:
>>
>> [bnx2x_extract_max_cfg:1074(eth4)]Illegal configuration detected for Max
>> BW on vn 2 - using 100 instead
>> [bnx2x_extract_max_cfg:1074(eth5)]Illegal configuration detected for Max
>> BW on vn 2 - using 100 instead
>> [bnx2x_extract_max_cfg:1074(eth6)]Illegal configuration detected for Max
>> BW on vn 3 - using 100 instead
>> [bnx2x_extract_max_cfg:1074(eth7)]Illegal configuration detected for Max
>> BW on vn 3 - using 100 instead
>>
>> This suggests that VNs 0 and 1 had non-zero Max BW configuration.
>
> Michal - this is a great point of data! It helped me finding a bug in
> that code - the code is not suitable for 4 port devices, it always
> assumes 4 VN per PCI function, while in 4 port devices there are only 2
> VN per PCI function. I assume that you are seeing this problem on a
> 57800 with 2x10G + 2x1G - and the 1G devices are in single function mode
> and therefore you are seeing this error message. I will send a patch to
> fix the problem on 4 port devices soon (after testing it for a while) -
> please confirm that you are seeing this issue on 2x10G+2x1G 57800
> device.

Eilon,
the tester is seeing this with BCM57711E. It's a HP-Blade bl460c-g6 with 
HP VirtualConnect. Quote from him:

   hp-agents reports 4 dual port nic's, Linux kernel reports 8 identical
   nic's but it's actual a blade with 2 LOM's (lan on motherboard) with
   each one port. Via VC we present max 4 FlexNic's per port, but for
   this server we present 2 FlexNic's per port.

   The fun with Linux is that it always sees all FlexNic's devices even
   if we configure 2 FlexNics via a VC profile on a port like on this
   server.

Michal
