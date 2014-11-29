From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Sat, 29 Nov 2014 02:49:51 -0200
Message-ID: <5479506F.6000803@redhat.com>
References: <5478CC27.9040705@redhat.com> <20141128203733.GD29748@ZenIV.linux.org.uk> <5478F2BB.9050409@redhat.com> <20141128223503.GE29748@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev <netdev@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbaK2EuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2014 23:50:00 -0500
In-Reply-To: <20141128223503.GE29748@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28-11-2014 20:35, Al Viro wrote:
> On Fri, Nov 28, 2014 at 08:10:03PM -0200, Marcelo Ricardo Leitner wrote:
>>> Could you print vnet_hdr_sz and sizeof(gso) right after that
>>> copy_from_iter(&gso, ...)?
>>
>> Did a:
>>          else {
>>                  err = skb_copy_datagram_from_iter(skb, 0, from, len);
>> +               pr_err("vnet_hdr_sz=%d sizeof(gso)=%lu\n",
>> tun->vnet_hdr_sz, sizeof(gso));
>>                  if (!err && msg_control) {
>>
>> Got, for tun:
>> [   50.514165] tun: vnet_hdr_sz=12 sizeof(gso)=10
>>
>> for tap:
>> [   82.911840] tun: vnet_hdr_sz=10 sizeof(gso)=10
>>
>> other values were just as before.
>
> Hmm...  Do you have
> commit 8c847d254146d32c86574a1b16923ff91bb784dd
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Thu Nov 13 16:54:14 2014 +0800
>
>      tun: fix issues of iovec iterators using in tun_put_user()
> in your tree?
>

Yes I have. I'm using based on net-next's 
799d2fff1858004526ad75d66a5dd8a5cce6ad40.

Marcelo
