From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next v2] vxlan: synchronously and race-free
 destruction of vxlan sockets
Date: Fri, 15 Apr 2016 18:47:59 -0300
Message-ID: <5711618F.1080302@gmail.com>
References: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
 <CAM_iQpUbTz2dRS+ZTZSSL0AvkOb_2_HEfXo+ap9__aQZmajMjA@mail.gmail.com>
 <1460159706.2880965.573380353.39845928@webmail.messagingengine.com>
 <20160415135832.773707e3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Benc <jbenc@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35957 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbcDOVsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 17:48:07 -0400
Received: by mail-qg0-f42.google.com with SMTP id f52so88964337qga.3
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 14:48:06 -0700 (PDT)
In-Reply-To: <20160415135832.773707e3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 15-04-2016 17:58, Stephen Hemminger escreveu:
> On Sat, 09 Apr 2016 01:55:06 +0200
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>
>>
>>
>> On Sat, Apr 9, 2016, at 01:24, Cong Wang wrote:
>>> On Fri, Apr 8, 2016 at 1:55 PM, Hannes Frederic Sowa
>>> <hannes@stressinduktion.org> wrote:
>>>> Due to the fact that the udp socket is destructed asynchronously in a
>>>> work queue, we have some nondeterministic behavior during shutdown of
>>>> vxlan tunnels and creating new ones. Fix this by keeping the destruction
>>>> process synchronous in regards to the user space process so IFF_UP can
>>>> be reliably set.
>>>>
>>>> udp_tunnel_sock_release destroys vs->sock->sk if reference counter
>>>> indicates so. We expect to have the same lifetime of vxlan_sock and
>>>> vxlan_sock->sock->sk even in fast paths with only rcu locks held. So
>>>> only destruct the whole socket after we can be sure it cannot be found
>>>> by searching vxlan_net->sock_list.
>>>>
>>>
>>> I am wondering what is the reason why we used work queue from
>>> the beginning?
>>
>> I actually don't know. It was like that from the beginning. I cc'ed
>> Stephen, maybe he remembers?
>>
>> Bye,
>> Hannes
>
> The problem was that VXLAN needs to update multicast settings and that
> can't be done under RTNL.

If the socket destroy was delayed just due to this, it should be all 
good then, because I took care of this multicast issue on commits

56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
54ff9ef36bdf ("ipv4, ipv6: kill ip_mc_{join, leave}_group and 
ipv6_sock_mc_{join, drop}")

   Marcelo
