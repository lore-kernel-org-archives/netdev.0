From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Wed, 07 Aug 2013 09:39:09 +0200
Message-ID: <5201F99D.2060809@redhat.com>
References: <20130801121142.GA444@www.manty.net> <51FB9EE5.3040907@redhat.com> <CAJk_L2FJyD2X7EPztiVWLBD4NDR_VOehdFEeV+nq7a+sO9+_wA@mail.gmail.com> <CAJk_L2FU6GcHUoC+UdNJoULN9KewoUQAMhapC0k3RcTqNOymnw@mail.gmail.com> <51FF7DC6.7080602@redhat.com> <CAJk_L2FTs0bX_s+ChKY9ZvZqVTagE=LQZpwV48b1RFhgtMsd8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Santiago Garcia Mantinan <manty@manty.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932240Ab3HGHjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 03:39:42 -0400
In-Reply-To: <CAJk_L2FTs0bX_s+ChKY9ZvZqVTagE=LQZpwV48b1RFhgtMsd8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2013 09:26 AM, Santiago Garcia Mantinan wrote:
> 2013/8/5 Nikolay Aleksandrov <nikolay@redhat.com>:
>>>         bond-arp_validate 0
>> No, because we take the first non-vlan's interface trans_start after the patch
>> which in this case is a bonding interface which also doesn't update its
>> trans_start, i.e. bond over bond (or over vlans over bond) with arp monitoring
>> shouldn't work.
> 
> Ok, after several days of testing it seems to work ok if I go with
> arp_validate 0, going for arp_validate 1 would cause the link failure
> count to be increased from time to time, is this ok?
> 
> Regards.
> 
If arp_interval is changed then you have to disable the interface (e.g.
ifconfig bondX down) and enable it again (ifconfig bondX up), or set it
while the interface is down. Also there're pr_debug()s in bond_validate_arp
and bond_arp_rcv that you can enable to check if it's validated properly.
