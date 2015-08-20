From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Thu, 20 Aug 2015 16:31:11 +0200
Message-ID: <55D5E4AF.7020409@6wind.com>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>	<1439966648-26195-1-git-send-email-vincent@bernat.im>	<1439966648-26195-2-git-send-email-vincent@bernat.im>	<20150819130013.1a847627@griffin>	<87bne38oj7.fsf@zoro.exoscale.ch>	<20150819143800.6863fa3b@griffin>	<8737zf8mwd.fsf@zoro.exoscale.ch>	<55D4AFCA.7080300@6wind.com> <20150820135307.3ce12f69@griffin>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vincent Bernat <vincent@bernat.im>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36688 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbbHTObQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:31:16 -0400
Received: by pawq9 with SMTP id q9so29528763paw.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:31:15 -0700 (PDT)
In-Reply-To: <20150820135307.3ce12f69@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/08/2015 13:53, Jiri Benc a =E9crit :
> On Wed, 19 Aug 2015 18:33:14 +0200, Nicolas Dichtel wrote:
>> Probably better to introduce veth netlink attribute then, something =
like
>> IFLA_VETH_PEER and keeps IFLA_LINK_NETNSID.
>
> I'd prefer IFLA_PEER. More generic attribute will be helpful should w=
e
> introduce an interface similar to veth in the future.s
Ok.

>
> Also, I'd not combine IFLA_LINK_NETNSID with IFLA_PEER. There might
> very well be an interface in the future that will need both IFLA_LINK=
 and
> IFLA_PEER and this would just create a confusion. It may be unlikely
> but the attributes are cheap and it doesn't make sense to design uAPI
> in a way that might bring problems in the future.
Ok, but then this IFLA_PEER can include the ifindex and the nsid. No ne=
ed
to have two new attributes.

>
>> I also don't know what is the best way to handle this. veth advertis=
es
>> its peer via IFLA_LINK since 4.1, so it's too late to change it for =
this
>> release.
>
> Apparently we need to pick our poison. Either way, we break something=
=2E
Sure. I would prefer to have the same mechanism in all version, but I c=
an
live with the other solution.

David, any thoughts about this?
