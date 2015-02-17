From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: getting a list of naked interface names from iproute2
Date: Tue, 17 Feb 2015 10:23:58 -0500
Message-ID: <20150217102358.67b9d826@uryu.home.lan>
References: <54E28630.4020200@mthode.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matthew Thode <mthode@mthode.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:32929 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbbBQPYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 10:24:01 -0500
Received: by mail-qa0-f53.google.com with SMTP id k15so26759509qaq.12
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 07:24:00 -0800 (PST)
In-Reply-To: <54E28630.4020200@mthode.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Feb 2015 18:07:12 -0600
Matthew Thode <mthode@mthode.org> wrote:

> iproute2 seems to like to add @ and : info to it's output.  This makes
> parsing it hard for things like neutron (openstack).  I have a patch to
> slightly update it (still missing some things, I'll link it at the end
> if interested).  Is there a better way of getting interface names from
> iproute2 without having to strip out at characters like '@' and ':'?
> 
> changeset in neutron: https://review.openstack.org/#/c/154128/
> link to current code:
> https://github.com/openstack/neutron/blob/master/neutron/agent/linux/ip_lib.py#L110-L131
> 
> I'd appreciate your help, I'd rather not have to go through each link
> type to pull it's delimiter, but if needed I guess it's needed.
> 

Stop screenscraping, and use a real API.
All of the above would work better:
  1. Libc if_nameindex
  2. Legacy ioctl(SIOCGIFCONF)
  3. Netlink  NLMMSG_REQ (RTM_GETLINK)
  4. Sysfs /sys/class/net
