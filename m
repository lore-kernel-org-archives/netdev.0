From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: Question regarding MAC address configuraton with VLAN devices
Date: Wed, 8 Apr 2015 10:16:32 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63C262F2@avmb3.qlogic.org>
References: <31AFFC7280259C4184970ABA9AFE8B93E0930C40@avmb3.qlogic.org>
 <5523FB49.9010107@redhat.com>
 <B5657A6538887040AD3A81F1008BEC63C26107@avmb3.qlogic.org>
 <20150408092016.GA27193@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37337 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753120AbbDHKQs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 06:16:48 -0400
In-Reply-To: <20150408092016.GA27193@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I think there's an even simpler question here - Today, if you'll have
> > a network interface with a vlan stacked on top of it and user calls
> > 'ip link set ... address ...' the end result would be that the vlan
> > interface retains the original MAC and push it downward [to base device].
> > You can claim this is harmless, but I don't really think anyone
> > intends this to happen.
> 
> If it wasn't intended, why would anyone write the code doing the sync (and
> switching to promiscuous mode as a fallback)?

I Didn't mean there's NO use-case where this is intended [e.g, this reflects
the logic behind the vlanmac configuration just fine] - I meant that it's
probably not the intended behavior for a plain vlan interface.

> The way I see it, there were two options:
> 
>   (a) add upper device's address to lower device's uc list
>   (b) propagate changed MAC address upwards
> 
> And the decision was to choose (a). While (b) might make some things simpler
> (and others more complicated), changing the behaviour now when people are
> used to it would be IMHO very unfortunate.
> 
>                                                         Michal Kubecek

I agree, although I'm not sure (a) and (b) can't co-exist under some strict set 
of rules.

I was thinking of perhaps marking the netdevice when eth_hw_addr_inherit() is
called, and unmark that flag on dev_set_mac_address(), assuming that as long
as a different MAC wasn't explicitly configured, the device should continue
inheriting the real dev MAC; But I think that would pose problems with APIs
that change the 'dev_addr' without the ndo, e.g., bonding devices.
 
