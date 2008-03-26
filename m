From: Patrick McHardy <kaber@trash.net>
Subject: Re: [UML]: uml-net: don't set IFF_ALLMULTI in set_multicast_list
Date: Wed, 26 Mar 2008 07:13:51 +0100
Message-ID: <47E9E99F.5080003@trash.net>
References: <47E9E331.1010105@trash.net> <47E9E8CD.1060408@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jdike@addtoit.com, user-mode-linux-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:57850 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751938AbYCZGNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 02:13:55 -0400
In-Reply-To: <47E9E8CD.1060408@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
>>  static void uml_net_set_multicast_list(struct net_device *dev)
>>  {
>> -    if (dev->flags & IFF_PROMISC)
>> -        return;
>> -    else if (dev->mc_count)
>> -        dev->flags |= IFF_ALLMULTI;
>> -    else dev->flags &= ~IFF_ALLMULTI;
>> +    return;
>>  }
> 
> 
> 
> Might as well just delete the hook at that point...


I kept it so SIOCADDMULTI/SIOCDELMULTI ioctls continue to
work on UML devices. I don't know if any userspace applications
check for errors when using these ioctls, this way nothing
can break.
