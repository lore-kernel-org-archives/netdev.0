From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: How to test netfilter SYNPROXY target properly?
Date: Fri, 3 Jan 2014 09:24:15 -0800
Message-ID: <CAK3+h2yNp9W3QrKVPR6EDct==xA8g9aq4ho6Aq_syYv-bkGN3w@mail.gmail.com>
References: <CAK3+h2wX3PvcMyNhYWYTnxyQyr9YN_2Mzr21gD4OrpF2P6+TcQ@mail.gmail.com>
	<20140103131908.GA26268@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140103131908.GA26268@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Patrick, put SYNPROXY in FORWARD did it.

On Fri, Jan 3, 2014 at 5:19 AM, Patrick McHardy <kaber@trash.net> wrote:
> On Thu, Jan 02, 2014 at 03:30:21PM -0800, Vincent Li wrote:
>> Hi Patrick
>>
>> I should have put this question in user list instead of dev list, but
>> I couldn't find any user based documentation on how to test the
>> SYNPROXY target other than the message in the SYNPROXY patch series.
>> so here is my setup:
>>
>> ---packet flow
>>
>> client 10.1.72.99 (vlan 1101)  <->Linux with SYNPROXY rule - 10.1.72.9
>> (vlan 1101) 10.2.72.139 (vlan 1102) <->server 10.2.72.99
>> ...
>> /usr/local/sbin/iptables -A INPUT -i $EXTIF -p tcp --dport 80 -m state
>> --state UNTRACKED,INVALID -j SYNPROXY --sack-perm --timestamp --mss
>> 1460 --wscale 5
>> 00000000        00000000
>>
>> I think I might miss something and not testing the SYNPROXY properly, any clue?
>
> I guess you need to put the SYNPROXY rule in FORWARD instead of INPUT.
