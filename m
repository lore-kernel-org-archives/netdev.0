From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Fri, 24 Apr 2009 23:16:33 +0200
Message-ID: <20090424231633.2dc051aa@neptune.home>
References: <20090422055735.GA4334@night.netis.ru>
	<m1hc0fuevi.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Alexander V. Lukyanov" <lav@netis.ru>,
	linux-kernel@vger.kernel.org, <netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp-110-77.adsl.restena.lu ([158.64.110.77]:54076 "EHLO
	bonbons.gotdns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbZDXVWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 17:22:53 -0400
In-Reply-To: <m1hc0fuevi.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 April 2009 ebiederm@xmission.com (Eric W. Biederman) wrote:
> "Alexander V. Lukyanov" <lav@netis.ru> writes:
> 
> > Eventually I have an increased load average without apparent reason.
> > When I reboot the server in such a case, I get infinitely repeating
> > messages on the console:
> >
> > unregister_netdevice: waiting for eth0.2 to become free. Usage
> > count = 4
> >
> > eth0.2 is a vlan interface, eth0 is 02:00.0 Ethernet controller:
> > Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit
> > Ethernet controller (rev 01)
> 
> CC: netdev where someone might have a better clue.
> 
> Infinitely repeating unregister_netdevice messages means something
> isn't releasing it's reference count to your network device.
> 
> There really isn't enough information in your email to figure out
> what you were doing that, or what piece of code triggered this.


A few I similar cases I have encountered are related to:
  vlan, netconsole

If you attempt to rmmod the driver of a network interface for which
you have a vlan or netconsole setup on top of you end up with this
kind of lock.

At least the two above do not react of removal attempt notifications
and thus keep the network device referenced.

Bruno
