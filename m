From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 00/13] Change DSA's FDB API and perform switchdev cleanup
Date: Wed, 19 Jul 2017 16:17:08 -0400
Message-ID: <87mv80ji63.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1500480294-10604-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44748 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754211AbdGSUTw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 16:19:52 -0400
In-Reply-To: <1500480294-10604-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arkadi,

I am testing your patch series the behavior changes suspiciously:

    # brctl show br0
    bridge name	bridge id		STP enabled	interfaces
    br0		8000.f6d5ef06ccdd	no		lan0
                                                        lan1
                                                        lan2
                                                        lan3
                                                        lan4
                                                        lan5
                                                        lan6
                                                        lan7
                                                        lan8
                                                        optical3
                                                        optical4

Without the patchset I have this behavior:

    # bridge fdb add 00:11:22:33:44:55 dev lan4
    # bridge fdb add 22:33:44:55:66:77 dev lan2 self
    # bridge fdb show                               
    01:00:5e:00:00:01 dev eth0 self permanent
    01:00:5e:00:00:01 dev eth1 self permanent
    0a:3f:f6:06:a2:ee dev lan0 master br0 permanent
    22:33:44:55:66:77 dev lan2 self static
    00:11:22:33:44:55 dev lan4 self static
    01:00:5e:00:00:01 dev br0 self permanent

And now with the patchset applied I have:

# bridge fdb add 00:11:22:33:44:55 dev lan4
# bridge fdb add 22:33:44:55:66:77 dev lan2 self
# bridge fdb show
01:00:5e:00:00:01 dev eth0 self permanent
00:11:22:33:44:55 dev eth1 self permanent
22:33:44:55:66:77 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
0a:ca:c8:6b:05:65 dev lan0 master br0 permanent
01:00:5e:00:00:01 dev br0 self permanent


It looks like the FDB entries are reported to be associated with the
master net device (eth1). Is the dump broken or is it the whole add?

Thanks,

        Vivien
