From: jamal <hadi@cyberus.ca>
Subject: Re: Resend: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 08:08:47 -0400
Message-ID: <1192536528.4480.65.camel@localhost>
References: <ifgroup.20071015.1192520046.panther@balabit.hu>
	 <a6713ba13c49b7fa20073d8abf1862480c2799e0.1192457385.git.panther@balabit.hu>
	 <1192531516.4480.33.camel@localhost>  <47149B04.30607@balabit.hu>
	 <1192534002.4480.52.camel@localhost>  <4714A4C3.10103@balabit.hu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: panther@balabit.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4714A4C3.10103@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-16-10 at 13:47 +0200, Laszlo Attila Toth wrote:

> Hm, the main problem (for me) is that it requires more then one value 
> per net device and it should be limited. But if I say it is 5 for 
> instance, anyone can say it is not enough for him.

Yes, those pesky humans, you give them an inch and they want a mile ;->
I think 32 for example is better than 1. So if you use a u32 variable
doesnt pollute the netdevice that much - and used as a bitmap, then
setting any of the 32 bits implies the device is in that group. This of
course limits the group ids to be (1..32). Your mileage may vary.

> ip link set ppp0 group 10
> also if "ip link set..." works for multiple interfaces it is already 
> done. If it is not, it will affect positively all other settings :)

nice.
The part that is not very useful today with ifconfig or ip link ls is i
have only two choices: Either i ask for all devices or for one; i cant
ask for something in the middle. If i can group them together then i can
solve that problem sith some user space plumbing (which avoids 10K
netlink messages). 
"get ppp*" may actually be a totally separate call which also traverses
the list in the kernel and just returns the matching devices. 

cheers,
jamal

