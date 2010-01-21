From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Thu, 21 Jan 2010 14:02:49 +0100
Message-ID: <4B585079.1070904@trash.net>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B55D372.4020807@gmail.com>    <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B5773C2.2010000@simon.arlott.org.uk>    <alpine.LSU.2.01.1001202238400.18680@obet.zrqbmnf.qr>    <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>    <4B578E59.8090203@trash.net> <0b01c450344abffd72a5b1b037ee6584e6db6b82@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <0b01c450344abffd72a5b1b037ee6584e6db6b82@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Arlott wrote:
> On Wed, January 20, 2010 23:14, Patrick McHardy wrote:
>> Jan Engelhardt wrote:
>>>> Can you explain why the automatic addition of a MSS option is removed?
>>> That is, of course, for the git log. If I followed the thread right, it
>>> was that adding the option could exceed the MTU. Well, can't we check
>>> for the outgoing MTU?
>> We certainly can, and in fact the packet would get fragmented
>> by the IP layer in case we would exceed the PMTU. Additionally
>> we currently check that the packet contains no data, even with
>> the first version of this patch, so there's no way the packet
>> could exceed the MTU.
> 
> If DF is set and the MTU is exceeded (for the SYN packet) at a
> hop further away, the original host will not understand that it
> needs to allow for the MSS option being added.

Yes, but we don't add it for SYNs containing data.

> (Header + Data + New MSS Option) can't exceed 576 bytes and
> there's no way to know that more than 576 bytes is allowed
> because the ICMP error message may not go via the same host that
> is mangling the packet.
> 
> Of course, it could just allow fragmentation for this one SYN
> packet but that doesn't work for IPv6.
> 
>> This feature has been there from day one since the TCPMSS target
>> has been merged and people are using this with knowledge of their
>> MTUs to work around broken ISPs. I'm not apply this.
> 
> The TCPMSS target can be applied to more than just one direction
> of traffic. I'm modifying incoming traffic too, so adding the MSS
> option and setting it to over 536 is wrong (although the first ICMP
> error will fix it).

It might be wrong, but so is dropping ICMP fragmentation required
packets. This is a workaround for broken behaviour and you should
of course only use MSS values that you know are valid.

> Existing users use this target precisely because their hosts are
> sending an unwanted MSS value, so it will never need to be added.

Its mainly used for ISPs surpressing ICMP fragmentation required
messages. That affects hosts not adding an MSS option as well.

>> The first version seemed fine to me though :)
> 
> The first version is ok with me. Only SYN packets with data and
> no MSS option will be dropped. William objects to ever adding the
> MSS option.

Well, he's about 10 years late.

> Although ideally SYN packets with data and no MSS option should
> be accepted without adding an option. Dropping arbitrary traffic
> (especially when new kernels allow data to be sent with SYN
> packets) is not a good idea. If that is ok with you then I'll
> make another patch to do it and update the comments.

I agree, it shouldn't drop packets unless it really has to.
Please go ahead with a new patch.
