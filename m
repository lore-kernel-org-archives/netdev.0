From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Wed, 20 Jan 2010 21:51:33 +0000
Message-ID: <4B577AE5.6080303@simon.arlott.org.uk>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B55D372.4020807@gmail.com> <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid> <4B5773C2.2010000@simon.arlott.org.uk> <alpine.LSU.2.01.1001202238400.18680@obet.zrqbmnf.qr> <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/01/10 21:41, Jan Engelhardt wrote:
> On Wednesday 2010-01-20 22:39, Jan Engelhardt wrote:
> 
>>On Wednesday 2010-01-20 22:21, Simon Arlott wrote:
>>
>>>The TCPMSS target is dropping SYN packets where:
>>>  1) There is data, or
>>>  2) The data offset makes the TCP header larger than
>>>  the packet.
>>>
>>>Both of these result in an error level printk.
>>>
>>>This change fixes the drop of SYN packets with data
>>>(because the MSS option can safely be modified) and
>>>passes packets with no MSS option instead of adding
>>>one (which is not valid).
>>
>>Can you explain why the automatic addition of a MSS option is removed?
> 
> That is, of course, for the git log. If I followed the thread right, it 
> was that adding the option could exceed the MTU. Well, can't we check 
> for the outgoing MTU?

The MSS option is for the MRU of whoever sent the SYN packet. There's no
way of knowing this information so it's not possible to avoid using an
MSS that is too large. With no option, "any" segment size could be used,
which implies 536 to match the MRU of 576.

The other reason for not being able to add it is that it may increase the
packet size beyond an MRU/MTU limit if there is data. There's no guarantee
we'll see an ICMP error message if this occurs, because the limit doesn't
have to be local and the return path does not need to be the same. The
original host won't know that the packet is going to be increased in size.

-- 
Simon Arlott
