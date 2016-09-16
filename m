From: Anton Aksola <aakso@iki.fi>
Subject: Re: [PATCH v2] iproute2: build nsid-name cache only for commands
 that need it
Date: Fri, 16 Sep 2016 12:02:53 +0000
Message-ID: <20160916120252.GA2384@toys.tundra.dog-lvm.novalocal>
References: <20160916072225.GA10536@toys.tundra.dog-lvm.novalocal>
 <1cced3be-a4d4-ef04-6079-e65755d9975b@6wind.com>
 <CAMw6YJJuoA+Z_DQx8iSEkrurB4ZZN9MePtHEeW=q7t5aDvmSAA@mail.gmail.com>
 <905de9c1-1322-5468-5770-58f788cb972c@6wind.com>
 <CAAL2ahKKFWcxhA=k+=3Td8sb-upnRUFs373EOhkHDaxvcgYjOw@mail.gmail.com>
 <CAMw6YJJbx1HvkiPALfzVarRgeUyWjZ4K_Mrzz2VDH7yfoAg+7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-78.nebula.fi ([83.145.220.78]:58230 "EHLO smtp.nebula.fi"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752856AbcIPMCu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 08:02:50 -0400
Content-Disposition: inline
In-Reply-To: <CAMw6YJJbx1HvkiPALfzVarRgeUyWjZ4K_Mrzz2VDH7yfoAg+7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 02:25:40PM +0300, Vadim Kochan wrote:
> Anton, I just looked into tests after when I did post here. I am not
> sure it will be trivial,
> currently tests are running within separated network namespace by
> default (which I did) via
> 'unshare' tool, and now I see that it is better to call it explicitly
> from the each test case. So
> I am not sure netns related  tests might be valid if they will be ran
> after 'unshare -n', if yes - then there is no problem, otherwise
> it needs to be fixed somehow - I will try to do this.
>
(excuse my duplicate emails if any received)

It seems that mounts made after 'unshare -n' will propagate back:

[root@toys iproute2]# ip netns
[root@toys iproute2]# unshare -n
[root@toys iproute2]# ip netns add foo
[root@toys iproute2]# ip netns exec foo ip link add type dummy
[root@toys iproute2]# exit
logout
[root@toys iproute2]# ip netns
foo
[root@toys iproute2]# ip netns exec foo ip link show dev dummy0
6: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT
    link/ether ba:cc:6c:ca:2d:41 brd ff:ff:ff:ff:ff:ff

This doesn't seem to work with 'ip netns exec' as it makes sure mounts
do not propagate.

BR, Anton
