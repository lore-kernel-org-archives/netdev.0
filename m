From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Sun, 3 Sep 2017 21:58:55 +0300
Message-ID: <CAJ3xEMju8pPUTb87GJK6Jhkdz0E-5EjuG35tQJdttRhTGJgYtg@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
 <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
 <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
 <CAJ3xEMiNKVZnPcqDavmRduQjJRZSOZTFYOP1-ghpREXegLaB-A@mail.gmail.com> <CALx6S34c_Kw9MXxM9hxtps0pOQYScJHftzdJ_pun68xjQzcGHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33902 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdICS64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 14:58:56 -0400
Received: by mail-oi0-f52.google.com with SMTP id h70so880321oic.1
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 11:58:56 -0700 (PDT)
In-Reply-To: <CALx6S34c_Kw9MXxM9hxtps0pOQYScJHftzdJ_pun68xjQzcGHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 3, 2017 at 7:45 PM, Tom Herbert <tom@herbertland.com> wrote:
>> Re all sorts of udp encap, sure, we're all on the less-is-more thing and just
>> RSS-ing on the ip+udp encap header.

>> For GRE, I was trying to fight back that rss-ing on inner, but as
>> Saeed commented,
>> we didn't see something simple through which the HW can do spreading. To
>> make sure I follow, you are saying that if this is gre6 tunneling

> It's pretty common that HW does this since GRE is in widespread use for a while.

ECMP? I guess so


>> the sender side (ip6_tnl_xmit?) will set the IPv6 flow label in a
>> similar manner done by udp_flow_src_port? and
>> if the receiver side hashes on L3 IPv6 src/dst/flow label we'll get
>> spreading? nice!

> As long as the network devices support it.

yeah, hopefully upcoming devices will support the thing

>> Still, what do we do with IPv4 GRE tunnels? and what do we do with HW
>> which isn't capable to RSS on flow label?

> Throw it out and buy hardware that supports flow label! ;-)

still, we came across IPv4 GRE customer environments

> Seriously though, flow labels are the only reasonable way that RSS can
> be supported in IPv6. If a device tries to do DPI on IPv6 then they'll
> eventually need to be able to parse of some number of extension
> headers which unlike IPv4 is unbounded in size. So there are going to
> be circumstances in which a device either doesn't understand an EH, or
> the size of EHs blows it parsing buffer limit so it can't do the DPI.
> IMO, telling host implementations that we're not allowed to use
> extension headers because middleboxes can't support them is
> unacceptable...

makes sense to me

> Btw, these same arguments apply as to why CHECKSUM_COMPLETE is the
> only reasonable way to handle receive checksums in IPv6.

supported on mlx5
