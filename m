From: Andrey Wagin <avagin@gmail.com>
Subject: linux-next: unregister_netdevice: waiting for lo to become free.
 Usage count = 1
Date: Tue, 18 Aug 2015 18:24:57 +0300
Message-ID: <CANaxB-z52c-1jqN4fFFECpz1EaDC6B-62WyqtJqNJRiKLhyg7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:36197 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbbHRPY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 11:24:59 -0400
Received: by lbbpu9 with SMTP id pu9so105579218lbb.3
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 08:24:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

CRIU tests detetect that references on net devices leak on
4.2.0-rc6-next-20150817. Looks like it started with
v4.2-rc6-882-g3bfd847.

David, could you check your changes?

The problem can be reproduced by the following script:
ip netns add test
ip netns exec test ip link set lo up
ip netns exec test ip addr add 1.2.3.4 dev lo
ip netns exec test ip route add 1.2.3.5 dev lo
ip netns exec test ip route add 1.2.3.6 via 1.2.3.5
ip netns del test

You need to execute it twice.

Thanks,
Andrey
