From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Thu, 09 Jul 2015 20:12:13 -0600
Message-ID: <559F29FD.6090705@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>	<CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>	<559EAD2A.2090002@cumulusnetworks.com>	<CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com> <877fq894l8.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	hadi@mojatatu.com, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38797 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbGJCMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 22:12:18 -0400
Received: by igrv9 with SMTP id v9so3413806igr.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 19:12:18 -0700 (PDT)
In-Reply-To: <877fq894l8.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/9/15 7:36 PM, Eric W. Biederman wrote:
> Sowmini Varadhan <sowmini05@gmail.com> writes:
>
>> On Thu, Jul 9, 2015 at 7:19 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>
>>> On the to-do list to use cmsg to specify a VRF for outbound packets using
>>> non-connected sockets. I do not believe it is going to work, but need to
>>> look into it.
>>>
>>>> What about setting ipsec policy for interfaces in the vrf?
>>
>>  From a purely parochial standpoint, how would rds sockets work in this model?
>> Would the tcp encaps happen before or after the the vrf "driver" output?
>> Same problem for NFS.
>>
>>  From a non-parochial standpoint. There are a *lot* of routing apps that actually
>> need more visibility into many details about the "slave" interface: e.g., OSPF,
>> ARP snoop, IPSLA.. the list is pretty long.
>>
>> I think it's a bad idea to use a "driver" to represent a table lookup. Too many
>> hacks will become necessary.
>
> With respect to sockets there is also the issue that ip addresses are
> not per vrf.

IP addresses are per interface and interfaces are uniquely assigned to a 
VRF so why do you think IP addresses are not per VRF?

>  Which means things like packet fragmentation reassembly
> can easily do the wrong thing.  Similarly things like the xfrm for ipsec
> tunnels are not hooked into this mix.
>
> So I really do not see how this VRF/MRF thing as designed can support
> general purpose sockets.  I am not certain it can correctly support any
> kind of socket except perhaps SOCK_RAW.

Sockets bound to the VRF device work properly. Why do you think they won't?

>
> Which strongly suggests to me you can leave off the magic network device
> and simply add the fib_lookup logic that finds the base fib table by
> looking at the in coming network device.  That seems a whole lot simpler
> and a whole lot less surprising.  The better routing will work and
> people playing with sockets will clearly see the dangers.

I believe Hannes is looking at that approach. Hopefully patches will be 
available soon to have more meaningful conversations (e.g., LPC). As we 
move along with working patch sets we can compare and contrast the 2 
models -- what features do each enable and at what cost.

David
