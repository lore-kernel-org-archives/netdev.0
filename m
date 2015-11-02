From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: kernel panic in 4.2.3, rb_erase in sch_fq
Date: Mon, 02 Nov 2015 18:21:35 +0200
Message-ID: <85bcbc58ac49545080497d66bddfacd6@visp.net.lb>
References: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
 <1446477897.23275.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <bf7139bba27ed042a24daa128b475742@visp.net.lb>
 <1446480722.23275.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446480722.23275.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-11-02 18:12, Eric Dumazet wrote:
> On Mon, 2015-11-02 at 17:58 +0200, Denys Fedoryshchenko wrote:
>> On 2015-11-02 17:24, Eric Dumazet wrote:
>> > On Mon, 2015-11-02 at 16:11 +0200, Denys Fedoryshchenko wrote:
>> >> Hi!
>> >>
>> >> Actually seems i was getting this panic for a while (once per week) on
>> >> loaded pppoe server, but just now was able to get full panic message.
>> >> After checking commit logs on sch_fq.c i didnt seen any fixes, so
>> >> probably upgrading to newer kernel wont help?
>> >
>> > I do not think we support sch_fq as a HTB leaf.
>> >
>> > If you want both HTB and sch_fq, you need to setup a bonding device.
>> >
>> > HTB on bond0
>> >
>> > sch_fq on the slaves
>> >
>> > Sure, the kernel should not crash, but HTB+sch_fq on same net device is
>> > certainly not something that will work anyway.
>> Strange, because except ppp, on static devices it works really very 
>> well
>> in such scheme. It is the only solution that can throttle incoming
>> bandwidth, when bandwidth is very overbooked - reliably, for my use
>> cases, such as 256k+ flows/2.5Gbps and several different classes of
>> traffic, so using DRR will end up in just not enough classes.
>> 
>> On latest kernels i had to patch tc to provide parameter for orphan 
>> mask
>> in fq, to increase number for flows for transit traffic.
>> None of other qdiscs able to solve this problem, incoming bandwidth
>> simply flowing 10-20% more than set, but fq is doing magic.
>> The only device that was working with similar efficiency for such 
>> cases
>> - proprietary PacketShaper, but is modifying tcp window size, and 
>> can't
>> be called transparent, and also has stability issues over 1Gbps.
> 
> Ah, I was thinking you needed more like 10Gb traffic ;)
> 
> with HTB on bonding, we can use MQ+FQ on the slaves in order to use 
> many
> cpus to serve local traffic.
> 
> But yes, if you use HTB+FQ for forwarding, I guess the bonding setup is
> not really needed.
Well, here country is very underdeveloped in matters of technology. 10G 
interfaces appeared in some ISP only this year.
On the ppp interfaces where crash happening - it is even less bandwidth. 
Each user max 1-2Mbps(average usage 128kbps), 4.5k interfaces.
But i have some more heavy setups there, around 9k pppoe users 
terminated on single server, (means 9k interfaces), about 2Gbps traffic 
passing thru.
If i take non-FOSS solution, i will have to pay for software licenses 
$100k+, which is unbearable for local ISP. fq is not critical in this 
specific use case, i can use for ppp interfaces fifo or such, but i 
guess better to report a but :)
