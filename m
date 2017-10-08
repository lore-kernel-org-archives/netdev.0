From: David Ahern <dsahern@gmail.com>
Subject: RIF/VRF overflow in spectrum and reporting errors back to user
Date: Sun, 8 Oct 2017 14:10:33 -0600
Message-ID: <8d0df382-35d1-7991-1c39-9a2b5d5334e2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ido Schimmel <idosch@mellanox.com>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:55279 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdJHUKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 16:10:36 -0400
Received: by mail-pf0-f176.google.com with SMTP id m28so6879892pfi.11
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 13:10:36 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri / Ido:

I am looking at adding user messages for spectrum failures related to
RIF and VRF overflow coming from the inetaddr and inet6addr notifier
paths. The key is that if the notifiers fail the address add needs to
fail and an error reported to the user as to what happened.

Earlier this year 3ad7d2468f79f added in_validator_info and
in6_validator_info as a way for the notifiers to fail adding an address.
Adding support to spectrum for that notifier is complicated by the fact
that the validator notifier and address notifiers will come in back to
back for the NETDEV_UP case. Ignoring NETDEV_UP in
mlxsw_sp_inetaddr_event seems ok for IPv6 but not clear for IPv4 since
the NETDEV_UP case is emitted on an address delete that involves a
promotion. Handling the back to back NETDEV_UP is complicated since
functions invoked by __mlxsw_sp_inetaddr_event can take multiple
references. Specifically, in mlxsw_sp_port_vlan_router_join():
    fid = rif->ops->fid_get(rif);

Can NETDEV_UP be ignored for the inetaddr notifier if it is handled by
the validator notitifer?

David
