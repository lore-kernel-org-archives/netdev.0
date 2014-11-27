From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH rfc] packet: zerocopy packet_snd
Date: Thu, 27 Nov 2014 09:18:12 +0008
Message-ID: <1417079412.18179.3@smtp.corp.redhat.com>
References: <1416602694-7540-1-git-send-email-willemb@google.com>
	<20141126182445.GA15744@redhat.com>
	<CA+FuTSdYB4rDMH3gAAMwaRdbqN58f_SxLz=C3fcCACw_KosGXw@mail.gmail.com>
	<20141126211748.GA11904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: Willem de Bruijn <willemb@google.com>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932102AbaK0JKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2014 04:10:30 -0500
In-Reply-To: <20141126211748.GA11904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Nov 27, 2014 at 5:17 AM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> On Wed, Nov 26, 2014 at 02:59:34PM -0500, Willem de Bruijn wrote:
>>  > The main problem with zero copy ATM is with queueing disciplines
>>  > which might keep the socket around essentially forever.
>>  > The case was described here:
>>  > https://lkml.org/lkml/2014/1/17/105
>>  > and of course this will make it more serious now that
>>  > more applications will be able to do this, so
>>  > chances that an administrator enables this
>>  > are higher.
>>  
>>  The denial of service issue raised there, that a single queue can
>>  block an entire virtio-net device, is less problematic in the case 
>> of
>>  packet sockets. A socket can run out of sk_wmem_alloc, but a prudent
>>  application can increase the limit or use separate sockets for
>>  separate flows.
> 
> Socket per flow? Maybe just use TCP then?  increasing the limit
> sounds like a wrong solution, it hurts security.
> 
>>  > One possible solution is some kind of timer orphaning frags
>>  > for skbs that have been around for too long.
>>  
>>  Perhaps this can be approximated without an explicit timer by 
>> calling
>>  skb_copy_ubufs on enqueue whenever qlen exceeds a threshold value?
> 
> Hard to say. Will have to see that patch to judge how robust this is.

This could not work, consider if the threshold is greater than vring 
size
or vhost_net pending limit, transmission may still be blocked.
