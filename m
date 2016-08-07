From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: flow_dissector: Get vlan priority in addition to vlan id
Date: Sun, 7 Aug 2016 10:43:25 +0300
Message-ID: <CAJL1qvGt_QwecHfPMvkr54=uT8OBZ88DMmn5E=BQRpUWY6aHKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirva@gmail.com>, Or Gerlitz <ogerlitz@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: tom@herbertland.com, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34350 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbcHGHn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 03:43:26 -0400
Received: by mail-oi0-f65.google.com with SMTP id a135so14727421oii.1
        for <netdev@vger.kernel.org>; Sun, 07 Aug 2016 00:43:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom and Jiri,

I would like to add vlan priority to  __skb_flow_dissect.

In the current vlan tag implementation there isn't any room left to
vlan priority next to the vlan id.

struct flow_dissector_key_tags {
                u32         vlan_id:12,
                                flow_label:20;
};

According to the discussion between you two [1], I'll be happy to get
your advice about what is the best way of adding vlan priority?

My suggestion is to add new vlan tag struct, it will make the code
cleaner and since we have to add 3 bits to vlan priority any way it
won't add unnecessary physical address holes.

struct flow_dissector_key_tags {
                u32         flow_label:20;
};

struct flow_dissector_key_vlan {
                u16         vlan_id:12,
                                vlan_priority:3;
};

Thanks,
Hadar

[1] - http://marc.info/?l=linux-netdev&m=143232557025994&w=2
