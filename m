From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: non-OVS based vxlan config broken on 3.19-rc ?!
Date: Thu, 15 Jan 2015 10:20:22 -0200
Message-ID: <54B7B086.7080208@redhat.com>
References: <54B688D9.8030101@mellanox.com>	<20150114155208.GA24550@casper.infradead.org> <CAJ3xEMj+rjTmk2tbVCTMCp+7N0qwXBNf3JsbJEgh2qvq0jHmEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>, thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895AbbAOMUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:20:55 -0500
In-Reply-To: <CAJ3xEMj+rjTmk2tbVCTMCp+7N0qwXBNf3JsbJEgh2qvq0jHmEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-01-2015 18:55, Or Gerlitz wrote:
> On Wed, Jan 14, 2015 at 5:52 PM, thomas Graf <tgraf@suug.ch> wrote:
>> On 01/14/15 at 05:18pm, Or Gerlitz wrote:
>>> Guys, just realized that non-OVS based vxlan config is broken with
>>> 3.19-rc... I see that it works for me on 3.18.2 and breaks on 3.19-rc3
>>> (Linus tree). Tested over mlx4 (both offloaded and non offloaded modes) and
>>> igb, see below the simplest form I can see it breaks on 3.19-rcand works on
>>> 3.18
>>>
>>> Looking on tcpdump and stats, the arp reply arrives to the 3.19-rc host NIC
>>> driver but is dropped along the stack beforehanded to the vxlan driver, not
>>> sure where and why...
>>
>> As additional data point: I tested the VXLAN-GBP with iproute2 based tunnels
>> on net-next and that works fine. Driver used was a e1000 in KVM.
>
>
> mm, so net-next.git (3.20 candidate code) and 3.18 works, but @ least
> for me 3.19-rc doesn't - could you check if net.git works for you on
> iproute2 based tunnels in that env? just vxlan is enough.
>

Hi,

Just tested your commands on two virtual machines running virtio (same host), 
Linus' commit fb005c47f7b72edac50342b6af490af09854381b (which is 3.19.0-rc4+) 
and it worked just fine for me. That is, ping went through both ways without 
issues.

I'll still try with net.git..

Did you try dropwatch? If you add a neigh entry for the remote peer and ping 
flood it, you may spot it on dropwatch.

   Marcelo
