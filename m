From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next 01/19] bna: use ether_addr_copy instead of memcpy
Date: Thu, 11 Jun 2015 15:31:11 +0200
Message-ID: <55798D9F.8020309@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>	 <1433954605-22813-2-git-send-email-ivecera@redhat.com> <1433959033.32331.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752497AbbFKNao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:30:44 -0400
In-Reply-To: <1433959033.32331.16.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2015 07:57 PM, Joe Perches wrote:
> On Wed, 2015-06-10 at 18:43 +0200, Ivan Vecera wrote:
>> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>
> Have you verified that all of these are __aligned(2)?
>
> I haven't, but you should verify that you have in the
> commit log.
I have checked an alignment of all instances and they are all aligned 
properly... An exception is global variable bnad_bcast_addr, its 
alignment is 1 according __alignof__ but according generated assembly it 
is aligned to 2. Anyway I'm going to put __aligned directive for sure.

> btw: this use looks odd to me:
>
> static int
> bnad_set_mac_address(struct net_device *netdev, void *mac_addr)
> {
> 	int err;
> 	struct bnad *bnad = netdev_priv(netdev);
> 	struct sockaddr *sa = (struct sockaddr *)mac_addr;
> 	unsigned long flags;
>
> 	spin_lock_irqsave(&bnad->bna_lock, flags);
>
> 	err = bnad_mac_addr_set_locked(bnad, sa->sa_data);
>
> as it casts what seems to be a mac address to a
> sockaddr and uses a different offset for sa->sa_data
> than the mac_addr passed.
>
> and the mac_addr as it's void doesn't need a cast.
No, bnad_set_mac_address() is an implementation of 
.ndo_set_mac_address() and this is called with pointer to struct 
sockaddr. The mac_addr name is a little bit confusing.

Will post v2.

Ivan
