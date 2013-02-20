From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: netlink, =?UTF-8?Q?RTM=5FNEWTCLASS=2C=20nested=20attributes?=
Date: Thu, 21 Feb 2013 01:24:02 +0200
Message-ID: <3598cf904e2e235bc9060aa712dcce53@visp.net.lb>
References: <3a8fd12d117d2281ac90cce96c0d68f3@visp.net.lb>
 <20130220152130.72df1258@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <pablo@netfilter.org>,
	<jhs@mojatatu.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130220152130.72df1258@samsung-9>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013-02-21 01:21, Stephen Hemminger wrote:
> On Tue, 19 Feb 2013 23:45:25 +0200
> Denys Fedoryshchenko <denys@visp.net.lb> wrote:
>
>> Hi
>>
>> I tried recently to write my own tool based on amazing libmnl (which
>> makes understanding of netlink - easy), written
>> by Pablo Neira Ayuso, to manage QoS in Linux and faced problem, 
>> which i
>> think probably
>> a bug in handling netlink messages in kernel.
>>
>> For example if i send message, RTM_NEWTCLASS, after attribute
>> TCA_OPTIONS i have nested attributes,
>> for example in HTB: TCA_HTB_PARMS, TCA_HTB_RTAB, TCA_HTB_CTAB.
>> libmnl, if i use nested attribute, adding a bit to it, by OR -
>> NLA_F_NESTED(1 << 15).
>> If i remove this flag - everything works fine. And here is the case,
>> iproute2 tools
>> just update length of TCA_OPTIONS, without setting flag, and it 
>> works
>> because of that fine too.
>>
>> So there is basically 3 solutions:
>> 1)New function in libmnl to do nested attributes without setting by 
>> OR
>> flag
>> 2)AND-ing attribute type in kernel to ignore nested flag
>> 3)Keeping as is, who cares?
>>
>
> Several legacy netlink interfaces don't use NESTED flag. These are by
> now enshrined in ABI and can't change. In code, that uses libmnl, I 
> just
> manually clear the flag as needed and document why. This could
> be added to libmnl.

Thank you for clarification!

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
