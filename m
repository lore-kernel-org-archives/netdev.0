From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Tue, 19 Jan 2010 12:50:28 -0000
Message-ID: <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
References: <4B54CDE5.3070100@simon.arlott.org.uk>
    <4B5578A5.50705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev" <netdev@vger.kernel.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "William Allen Simpson" <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754063Ab0ASMuc@vger.kernel.org>
In-Reply-To: <4B5578A5.50705@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, January 19, 2010 09:17, William Allen Simpson wrote:
> Simon Arlott wrote:
>> The check for data only needs to apply where the packet length
>> could be increased by adding the MSS option. (The MSS option
>> itself applies to the sender's maximum receive size which is
>> not relevant to any data in its own packet.)
>>
>> This moves the check for (header size != packet size) to after
>> attempting to modify an existing MSS option. Another check is
>> needed before looking through the header to ensure it doesn't
>> claim to be larger than the packet size.
>>
>
> 2) There certainly *can* be data on SYN.  That code is already in
> 2.6.33....

I could change the comment too, but the same logic applies when
there is data and no MSS option - the packet can't be increased
in size if it would then exceed 576 bytes and/or the destination
MTU.

If it's possible to know that the packet can have an additional
option added without exceeding MTU then this could be changed.
The data part would need to be moved to make space at the end of
the header.

-- 
Simon Arlott
