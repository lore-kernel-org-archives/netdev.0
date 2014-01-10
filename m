From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 1/4] bonding: update the primary when slave name
 changed
Date: Fri, 10 Jan 2014 12:11:43 +0100
Message-ID: <20140110111143.GB4132@redhat.com>
References: <52CE8604.3010804@huawei.com>
 <20140109114636.GF5786@redhat.com>
 <52CE94DE.5030305@huawei.com>
 <20140109123019.GM5786@redhat.com>
 <52CF751D.1020200@huawei.com>
 <20140110074433.GA26273@redhat.com>
 <52CFD3FE.9000805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092AbaAJLOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 06:14:48 -0500
Content-Disposition: inline
In-Reply-To: <52CFD3FE.9000805@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 07:05:34PM +0800, Ding Tianhong wrote:
>On 2014/1/10 15:44, Veaceslav Falico wrote:
>> If it's not the primray
>> slave, and we don't have one - select it as a new primary and, again, see
>> if we need to select a new active slave.
>
>I don't think so , I think if it is not the primary slave and we don't have one,
>no need to do anything, just a normal slave change its name.

If primary == "my_eth0", you have 2 slaves - "eth0" and "eth1", thus null
primary_slave, and rename eth0 to my_eth0 - then you need to set
primary_slave to my_eth0.

If primary == "my_eth0", you have 2 slaves - "my_eth0" and "eth1", thus
primary_slave == dev with name "my_eth0", and rename "my_eth0" to "eth0" -
then you must set primary_slave to NULL.

And after either of these you must see if you need to re-select the active
slave, as it might have been forced by the primary_slave, which has been
modified.

You might also want to add some pr_info() about adding/removing
primary_slave, as the user to be aware.
