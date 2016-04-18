From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] macvlan: fix failure during registration
Date: Mon, 18 Apr 2016 16:33:07 -0500
Message-ID: <87wpnur4a4.fsf@x220.int.ebiederm.org>
References: <1460992811-46992-1-git-send-email-fruggeri@arista.com>
	<87ega2sqhf.fsf@x220.int.ebiederm.org>
	<CA+HUmGhUqXn35x6Nnhcrk+WH8PuiaxwsrZNy-NsJ94wybCukGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Francesco Ruggeri <fruggeri@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42336 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbcDRVnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 17:43:32 -0400
In-Reply-To: <CA+HUmGhUqXn35x6Nnhcrk+WH8PuiaxwsrZNy-NsJ94wybCukGA@mail.gmail.com>
	(Francesco Ruggeri's message of "Mon, 18 Apr 2016 13:10:51 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@arista.com> writes:

> On Mon, Apr 18, 2016 at 11:48 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> These interactions all seem a little bit funny.  At a quick skim it
>> would make more sense to increment the port count in macvlan_init,
>> and completely remove the need to mess with port counts anywhere except
>> macvlan_init and macvlan_uninit.
>
> Thanks Eric, let me try that.
>
>>
>> If for some reason that can't be done the code can easily look at
>> dev->reg_state.  If dev->reg_state == NETREG_UNITIALIZED it should
>> be exactly the same as your new flag being set.
>>
>
> I am not sure that in macvlan_uninit one can tell whether it is being
> invoked in the context of a failed register_netdevice (if that is what
> you meant).
>
> In case of register_netdevice failing in
> call_netdevice_notifiers(NETDEV_REGISTER) the call sequence is:
>
> macvlan_common_newlink
>   register_netdevice
>     call_netdevice_notifiers(NETDEV_REGISTER, dev) (<== fail here)
>       rollback_registered(dev);
>         rollback_registered_many
>           dev->reg_state = NETREG_UNREGISTERING
>           dev->netdev_ops->ndo_uninit(dev)
>       dev->reg_state = NETREG_UNREGISTERED;
>

The code I have looks a little different.  But that is a good point.

But please see if you can get macvlan_init to do the necessary work.
That should simplify everything, and make clever games unnecessary.

Eric
