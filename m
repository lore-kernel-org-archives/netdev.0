From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] net-driver: Drivers don't set IFF_* flag [Was: [PATCH
 3/3] netdevice: order of synchronization of IFF_PROMISC and	IFF_ALLMULTI]
Date: Tue, 24 Jun 2008 13:39:19 +0800
Message-ID: <48608887.6000102@cn.fujitsu.com>
References: <4857B6DC.5020805@trash.net> <48587295.40705@cn.fujitsu.com> <48587854.8050400@pobox.com> <485BC7BA.60406@cn.fujitsu.com> <485F8332.6010203@trash.net> <485FA635.4090903@cn.fujitsu.com> <485FA962.5060704@trash.net> <485FB6D1.7000604@cn.fujitsu.com> <485FB8B1.8020000@trash.net> <4860478B.2080109@cn.fujitsu.com> <20080624051029.GB19434@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Jeff Garzik <jgarzik@pobox.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>, kyle@parisc-linux.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60895 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751531AbYFXFn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 01:43:26 -0400
In-Reply-To: <20080624051029.GB19434@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler said the following on 2008-6-24 13:10:
> On Tue, Jun 24, 2008 at 09:02:03AM +0800, Wang Chen wrote:
> ...
>> So I want to remove "clear promisc" feature by ioctl of this driver
>> instead of adding it to feature-removal-schedule.
>> "set promisc" feature by ioctl can be fixed temporarily and should be
>> added to feature-removal-schedule. 
>> Fortunately most of the features of this driver's ioctl are for
>> developer testing.
>>
>> This week I want to wait for tulip driver maintainer's confirmation.
> 
> Confirmation of what?
> Apologies for not being able to follow the whole conversation.
> 

Sorry for that I cc-ed you in the mid of discussion.
Patrick and me were discussing about that driver should not
change device's promisc mode, because it's not a boolean state,
but a refcnt to decide whether IFF_PROMISC should be set or not.

In de4x5_ioctl(), user can simply set IFF_PROMISC flag and that
can cause upper layer protocol broken.

Patrick suggest to use dev_change_flags() to change IFF_PROMISC
flag and add the feature to feature-removal-schedule.

My suggestion is that we remove IFF_PROMISC changing feature from
de4x5_ioctl() now.

> If you want to remove a developer debug feature, please just submit
> a patch like usual to kyle and myself.
> 

Is there any user space binary use these features?
case DE4X5_SET_PROM:
case DE4X5_CLR_PROM: 
If not, I will send a patch to remove them.


