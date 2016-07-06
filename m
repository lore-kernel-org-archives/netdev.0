From: nuclearcat@nuclearcat.com
Subject: Re: 4.6.3 kernel panic on ppp interface termination
 (__tcf_hash_release / spinlock )
Date: Wed, 06 Jul 2016 23:14:22 +0300
Message-ID: <58100198b6d14f77ce95740e4e912fc3@nuclearcat.com>
References: <9b35b4153ec398e17cfb7c2739eee1de@nuclearcat.com>
 <31e51065f1531b4fa819dac37dc0ba11@nuclearcat.com>
 <CAM_iQpW0PPZJzhbaeNN1zYZsyopzAWiO1b13XAXZLjpPBKapxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:52304 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751629AbcGFUOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 16:14:31 -0400
In-Reply-To: <CAM_iQpW0PPZJzhbaeNN1zYZsyopzAWiO1b13XAXZLjpPBKapxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-07-05 01:02, Cong Wang wrote:
> On Mon, Jul 4, 2016 at 12:07 PM,  <nuclearcat@nuclearcat.com> wrote:
>> A little bit more details:
>> 
>>  ~ # tc -s -d filter show dev ppp0 parent ffff:
>> filter protocol ip pref 100 u32
>> filter protocol ip pref 100 u32 fh 800: ht divisor 1
>> filter protocol ip pref 100 u32 fh 800::1 order 1 key ht 800 bkt 0 
>> flowid :1
>> (rule hit 156 success 156)
>>   match 00000000/00000000 at 12 (success 156 )
>>         action order 1:  police 0x1 rate 4024Kbit burst 503000b mtu 
>> 2Kb
>> action drop overhead 0b linklayer unspec
>> ref 1 bind 1
>>         Action statistics:
>>         Sent 10564 bytes 156 pkt (dropped 0, overlimits 0 requeues 0)
>>         backlog 0b 0p requeues 0
>> 
>> 
>> Panic occurs when i delete ingress qdisc
>> 
>> tc qdisc del dev ppp0 ingress
>> 
>> After reversing commits (and some related commits)
>>         1d4150c02c5709fdfd80f10368a31867de35e72e
>>         ddf97ccdd7cb7e00daba465a5c947b8d941dc2a4
>> 
>> Problem is not occurring.
>> 
>> I'm not certainly sure this commits are causing issue, it is very hard 
>> to
>> reverse patches on this particular system.
>> 
> 
> Can you check if the following commit helps?
> 
> commit a03e6fe569713fb3ff0714f8fd7c8785c0ca9e22
> Author: WANG Cong <xiyou.wangcong@gmail.com>
> Date:   Mon Jun 6 09:54:30 2016 -0700
> 
>     act_police: fix a crash during removal
Yes, it fixes issue, thanks.
