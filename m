From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: bond procfs hw addr prints
Date: Mon, 13 Mar 2017 17:28:04 -0700
Message-ID: <10202.1489451284@famine>
References: <597da6f1-c0fc-ae23-94d1-d0fb3abb3176@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:57815 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdCNA2I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 20:28:08 -0400
In-reply-to: <597da6f1-c0fc-ae23-94d1-d0fb3abb3176@redhat.com>
Content-ID: <10201.1489451284.1@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarod Wilson <jarod@redhat.com> wrote:

>I've got a bug report for someone using a Intel OPA devices in a bond, and
>it appears these devices have a hardware address length of 20, opposed to
>the typical 6 on ethernet. When they dump /proc/net/bonding/bondX, it only
>prints the first 6 of the address, per %pM and mac_address_string(), while
>sysfs for the interface does print the right thing, since it uses
>sysfs_print_mac(), which takes a length argument.

	This (20 octet MAC length) is true for any Infiniband device.

>So the question is... What's the best route to take here? Expand %pM to
>support variable length hardware addresses? Use sysfs_* in procfs?
>Reinvent the wheel? Nothing I've tinkered with just yet feels very clean,
>on top of not actually working yet. :)

	sysfs_format_mac (not _print_mac) uses "%*phC", len, addr in its
format string.  Perhaps that format would be a better choice than %pM
for this case?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
