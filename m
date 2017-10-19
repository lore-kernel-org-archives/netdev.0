From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ip: introduce IFA_F_DHCP flag
Date: Thu, 19 Oct 2017 12:13:35 +0100 (WEST)
Message-ID: <20171019.121335.550725279635656330.davem@davemloft.net>
References: <1508350606-21218-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751529AbdJSLNn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:13:43 -0400
In-Reply-To: <1508350606-21218-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Wed, 18 Oct 2017 11:16:46 -0700

> This flag identifies that the address was obtained through DHCP.
> 
> Today there is no easy way to find out whether an address on an
> interface is DHCP controlled or is static. Either you will need to
> grep for 'dhclient' process (or something else in case one is using a
> different DHCP client) or if you are using NetworkManager (or some
> such), then you will need to query through their interface to find out
> if an address is DHCP or not.
> 
> This flag will be set by the DHCP clients in the userspace when it
> brings up the DHCP address on an interface. For example: ISC DHCP
> client (aka dhclient) today brings up the address on an interface by
> running ip-address(8) command (in dhclient-script). This command can
> be extended to include 'dhcp' keyword in its 'add' or 'replace'
> subcommand. Once this flag is set, the show subcommand can display the
> keyword 'dhcp' against the address to indicate that the address was
> obtained through DHCP.
> 
> This flag can also be set and obtained programmatically using
> AF_NETLINK. Besides providing observability, this flag will be useful
> for applications that need to prevent/allow certain settings on
> addresses based on whether they are DHCP or not.
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Well, two things.

if nobody has asked for this for 25+ years, I have serious doubts that
there is something fundamental you cannot do without this piece of
information.

Second, a lack of this flag being set won't mean "is static", it will
mean "might be STATIC, might be DHCP" and frankly that is completely
useless.  It is this way because you cannot have every dhcp agent on
every Linux system changed immediately.

I think it will give a false sense of accuracy, even on tightly
controlled sets of userspace components.

I'm not applying this, sorry.
