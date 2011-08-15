From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] bnx2x: suppress repeated error messages about Max BW
Date: Mon, 15 Aug 2011 17:13:28 +0200
Message-ID: <4E493798.7010405@redhat.com>
References: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com> <1313405680.31417.6.camel@lb-tlvb-eilong.il.broadcom.com> <4E490A1E.3060209@redhat.com> <1313411585.31417.35.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368Ab1HOPNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 11:13:32 -0400
In-Reply-To: <1313411585.31417.35.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2011 02:33 PM, Eilon Greenstein wrote:
> On Mon, 2011-08-15 at 04:59 -0700, Michal Schmidt wrote:
>> and bnx2x_init_vn_minmax() calls bnx2x_extract_max_cfg() on the given
>> VN, so it seems that the warning can be produced for a non-current VN.
>
> You are right, only one function (the PMF) will call this code for all
> functions. But I suspect that if you have zero values, you will have
> them for all VNs - is that the case?

A tester reported getting only these 4 messages with the patch applied:

[bnx2x_extract_max_cfg:1074(eth4)]Illegal configuration detected for Max 
BW on vn 2 - using 100 instead
[bnx2x_extract_max_cfg:1074(eth5)]Illegal configuration detected for Max 
BW on vn 2 - using 100 instead
[bnx2x_extract_max_cfg:1074(eth6)]Illegal configuration detected for Max 
BW on vn 3 - using 100 instead
[bnx2x_extract_max_cfg:1074(eth7)]Illegal configuration detected for Max 
BW on vn 3 - using 100 instead

This suggests that VNs 0 and 1 had non-zero Max BW configuration.

Michal
