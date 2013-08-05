From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 0/2] fix bonding neighbour setup handling
Date: Mon, 05 Aug 2013 15:49:08 +0200
Message-ID: <51FFAD54.7090501@redhat.com>
References: <1375463259-12033-1-git-send-email-vfalico@redhat.com> <20130802.154539.237539535236462726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, ebiederm@xmission.com, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255Ab3HENwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 09:52:47 -0400
In-Reply-To: <20130802.154539.237539535236462726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 12:45 AM, David Miller wrote:
> 
> Thanks for the detailed explanation of the situation, it made your patches
> trivial to review.
> 
> Applied, thanks.
Hi all,
Vaeceslav thanks for fixing this.
Since the cat is out of the bag about this bug, as Vaeceslav discovered it
independently and wasn't aware that there's a CVE number pending because it
poses a security threat since the dereferenced first_slave pointer is
taken from the struct vlan_dev_priv's ingress_priority map array which is
user-controllable and any memory address can be dereferenced in that way,
and taking after that first_slave->dev->netdev_ops and calling a function
from the ops is making it even easier. Of course for that to happen the
user must have CAP_NET_ADMIN.
I've tested these patches and they apply cleanly on -net as well, so please
queue them for -net and stable.

Also apologies for the late reply but it wasn't up to me when to reveal this.

Thank you,
 Nik
