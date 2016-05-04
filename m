From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net v2] vlan: Propagate MAC address to VLANs unless
 explicitly set
Date: Wed, 4 May 2016 09:14:32 -0700
Message-ID: <CAKgT0UeXXySmGSBoOTkJHfURHruEifN51Q+brWhJdpbFP8CNpw@mail.gmail.com>
References: <5728BA0B.6050807@brocade.com>
	<5728C1AC.3090708@brocade.com>
	<20160504092801.GC19967@unicorn.suse.cz>
	<20160504.115815.1348535190105538815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Kubecek <mkubecek@suse.cz>, mmanning@brocade.com,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35047 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182AbcEDQOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 12:14:33 -0400
Received: by mail-ig0-f178.google.com with SMTP id bi2so152650056igb.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 09:14:33 -0700 (PDT)
In-Reply-To: <20160504.115815.1348535190105538815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2016 at 8:58 AM, David Miller <davem@davemloft.net> wrote:
> From: Michal Kubecek <mkubecek@suse.cz>
> Date: Wed, 4 May 2016 11:28:02 +0200
>
>> The commit message says "unless explicitly changed for the VLAN" but
>> what you really check is "if it is the same as real device MAC address".
>> This, in general, is not the same. (I believe this is what David tries
>> to explain from the start.)
>
> Even more proof that these MAC checks are rediculous, confusing, and
> that we need to use a boolean state stores in the vlan private in
> order to implement the intended semantics properly and more importantly
> "clearly".

Actually last I knew the netdev already has a field called
addr_assign_type.  You could probably borrow some code from how
bonding is currently handling MAC addresses and apply it to VLANs to
achieve the effect you are looking for since I believe the default for
VLAN is similar to NET_ADDR_STOLEN and when it is set you would switch
that over to NET_ADDR_SET.

- Alex
