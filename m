From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [RFC PATCH net-next 2/5] net: split skb_checksum_help
Date: Tue, 28 Feb 2017 11:31:11 +0100
Message-ID: <1488277871.3248.34.camel@redhat.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
         <532e1db70b6c40f1b1e5c60b5b51be9f3437a30b.1485177252.git.dcaratti@redhat.com>
         <CALx6S37E=OEkRego_u=oDuUgQUn9-NZLpupvbN_dge1rqF92CQ@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DB026CEA4@AcuExch.aculab.com>
         <1486048043.2556.4.camel@redhat.com>
         <CALx6S34KvvLYo_wrnX-da5ok3Z4pcdyJxiLi63iHzno9j9L4Fg@mail.gmail.com>
         <1488202783.2713.67.camel@redhat.com>
         <CALx6S36bZ_tZrXxBj9fNActemMDKYJzA5K1vK9jVED9z9+FwBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Laight <David.Laight@aculab.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34564 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751728AbdB1Kba (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 05:31:30 -0500
In-Reply-To: <CALx6S36bZ_tZrXxBj9fNActemMDKYJzA5K1vK9jVED9z9+FwBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-27 at 07:11 -0800, Tom Herbert wrote:
> CHECKSUM_PARTIAL is the preferred mechanism on the transmit path this
> defers defers the checksum computation as long as possible.
> Unfortunately, if SCTP is encapsulated in UDP we will probably need to
> run the SCTP CRC on the host which will be done with your changes to
> skb_checksum_help.

right. Tunnel devices have NETIF_F_SCTP_CRC bit cleared and
NETIF_F_HW_CSUM bit set: so, in this case csum_not_inet can help
recovering non-GSO SCTP packets having ip_summed equal to
CHECKSUM_PARTIAL.

> > I'm not sure if setting CHECKSUM_UNNECESSARY fits my case, because this would
> > implicitly skip RX validation when using devices like veth or loopback.
> >
> CHECKSUM_UNNECESSARY can be used in the transmit path (really the
> forwarding path), however this I think this must imply that the
> checksum in the packet must be correct. Please see my post about
> drivers that are mistakingly using CHECKSUM_UNNECESSARY with LRO since
> the checksum in the packet sent into the stack is not correct.

Ok, now I'm more convinced to use CHECKSUM_NONE :-)

thank you for the attention!
regards
