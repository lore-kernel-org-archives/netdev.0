From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] bonding: move bond-specific init after
 enslave happens
Date: Tue, 22 Oct 2013 09:50:20 +0200
Message-ID: <20131022075020.GA1401@minipsycho.orion>
References: <1382348910-32724-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:56353 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab3JVHuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 03:50:23 -0400
Received: by mail-ee0-f44.google.com with SMTP id b47so4195649eek.17
        for <netdev@vger.kernel.org>; Tue, 22 Oct 2013 00:50:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1382348910-32724-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 21, 2013 at 11:48:30AM CEST, vfalico@redhat.com wrote:
>As Jiri noted, currently we first do all bonding-specific initialization
>(specifically - bond_select_active_slave(bond)) before we actually attach
>the slave (so that it becomes visible through bond_for_each_slave() and
>friends). This might result in bond_select_active_slave() not seeing the
>first/new slave and, thus, not actually selecting an active slave.
>
>Fix this by moving all the bond-related init part after we've actually
>completely initialized and linked (via bond_master_upper_dev_link()) the
>new slave.
>
>Also, remove the bond_(de/a)ttach_slave(), it's useless to have functions
>to ++/-- one int.
>
>After this we have all the initialization of the new slave *before*
>linking, and all the stuff that needs to be done on bonding *after* it. It
>has also a bonus effect - we can remove the locking on the new slave init
>completely, and only use it for bond_select_active_slave().
>
>Reported-by: Jiri Pirko <jiri@resnulli.us>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
