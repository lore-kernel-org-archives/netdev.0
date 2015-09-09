From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some issues
Date: Wed, 09 Sep 2015 11:22:58 +0200
Message-ID: <55EFFA72.2080600@iogearbox.net>
References: <20150814085807.GA30443@gmail.com> <55CDBC84.8020605@iogearbox.net> <55CDC51D.1060204@iogearbox.net> <20150817.140222.1763422851882964859.davem@davemloft.net> <55EDA536.10707@iogearbox.net> <20150909085333.GD5986@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chamaken@gmail.com,
	netdev@vger.kernel.org, fw@strlen.de
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33443 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbbIIJXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 05:23:04 -0400
In-Reply-To: <20150909085333.GD5986@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2015 10:53 AM, Thomas Graf wrote:
> On 09/07/15 at 04:54pm, Daniel Borkmann wrote:
>> On 08/17/2015 11:02 PM, David Miller wrote:
>> ...
>>> I would seriously rather see us do an expensive full copy of the SKB
>>> than to have traffic which is unexpectedly invisible to taps.
>>
>> I've been looking into this issue a bit further, so the copy for the
>> tap seems doable, but while further going through the code to find similar
>> issues elsewhere, and doing some experiments, it looks like we write
>> shared info also in some edge-cases of upcalls such as nfqueue or ovs
>> when mmaped netlink is used for rx. I did a test with nfqueue using
>> the libmnl mmap branch [1].
>
> Note that OVS does not utilize mmaped netlink even though it has been
> considered for a while. It is theoretically possible that non-OVS user
> space user of the OVS netlink API is using it although I'm not aware
> somebody actually does. We can probably fix this specifically for nfqueue.

Sure, I know, it's not included in OVS user space upstream. I meant the
kernel parts of these subsystems where it could be possible /iff/ there's
someone running a netlink socket in rx ring mode against it (but I have
no overview whether someone is doing this in the wild); sorry, should have
been more specific.

Netlink mmap is also not officially upstream in libmnl and neither in
libnetfilter_queue. It looks like it's sitting in the libmnl branch that
I mentioned, but didn't get merged so far. Afaik, Ken-ichirou was doing
work related to adapting this into netfilter in the past.

Anyway, I'll get the stuff ready tonight that I have so far wrt fixes.

Cheers,
Daniel
