From: Patrick McHardy <kaber@trash.net>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 14:41:22 +0200
Message-ID: <49F061F2.9000005@trash.net>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net> 	<alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr> 	<49F042E7.7060900@trash.net> <beb91d720904230412j4dea4034o61f2d0682ff76d1a@mail.gmail.com> 	<49F04F6B.7010709@trash.net> <beb91d720904230537s7f61c441g5af4a3acc1a0c2aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Salatiel Filho <salatiel.filho@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <beb91d720904230537s7f61c441g5af4a3acc1a0c2aa@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Salatiel Filho wrote:
> On Thu, Apr 23, 2009 at 08:22, Patrick McHardy <kaber@trash.net> wrote:
>> Salatiel Filho wrote:
>>> Using imq i can shape upload on ppp0 [postrouting] while still having
>>> the internal private ips from the hosts, and i can shape download in
>>> ppp0 [prerouting] after get the correct nat'ed addresses.
>>>
>>> Is there a way to achieve this in IFB ? in a simple way ... :)
>> Currently not, the conntrack association is done at a later point.
>> We could add a classifier or TC action that performs the lookup
>> during ingress classification.
>>
>> Alternatively classifiers using conntrack information (like cls_flow)
>> could perform the lookup directly, but that would probably get a bit
>> ugly since some validation needs to be performed previously and it
>> would add a module dependency on conntrack.
>>
>>
> Using this actions would make  sfq hashing by dest ip or source ip
> work just like it works in imq ?

Not with the SFQ default hash since it classifies based on the
addresses in the IP header. But you could use the flow classifier,
which can use the addresses from the conntrack entry. This would
behave similar to IMQ+SFQ.

