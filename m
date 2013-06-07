From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Generic interface to make physical port number used by a netdevice
 available to user space
Date: Fri, 07 Jun 2013 10:35:21 -0700
Message-ID: <51B219D9.2010900@gmail.com>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>  <20130523093421.3b20a0bd@nehalam.linuxnetplumber.net>  <E31FB011129F30488D5861F383904915210B96144A@BLRX7MCDC201.AMER.DELL.COM>  <20130531121201.GA1311@fedora-17-guest.blr.amer.dell.com>  <51B1F56D.5000007@intel.com> <1370625678.1903.26.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Narendra K <narendra_k@dell.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:51082 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755868Ab3FGRfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 13:35:34 -0400
Received: by mail-ob0-f171.google.com with SMTP id dn14so6983670obc.30
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 10:35:34 -0700 (PDT)
In-Reply-To: <1370625678.1903.26.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> Having looked at the qeth driver now, I think the comment in netdevice.h
> should be changed to state that this is for distinguishing devices that
> share a link-layer address, and the drivers using it for other purposes
> should stop doing so (if that doesn't break userland).
>

Agreed, the qeth driver eluded me, its not in ./drivers/net as you
noted in the other thread.

> [...]
>>> 3. Add a new field 'physport' to 'struct net_device' and export it to sysfs.
>>
>> Probably not we already have two fields that seem ill-defined no reason
>> to add another to the confusion. If you absolutely can't make dev_id or
>> if_port coherent then maybe but I really think one of the above two will
>> work.
>
> I think we should tighten up documentation and implementation of the
> existing fields, but there is still a need for this new one.
>
> One thing that needs to be clearly specified is the scope of the
> physport identifier - the controller, board, physical machine, ... or
> universe.  In a VM, controller and board scope are pretty useless as it
> typically can't tell which devices belong to the same controller or
> board anyway.  A universally unique identifier is probably not too hard
> to implement as there is likely to be at least one MAC address
> permanently assigned to each physical port.
>
> Ben.
>

OK, sounds reasonable to me a new field should work.


-- 
John Fastabend         Intel Corporation
