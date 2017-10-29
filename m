From: David Ahern <dsahern@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Sun, 29 Oct 2017 09:48:21 -0600
Message-ID: <abb3291a-222a-7eff-724c-9d06fea9f02d@gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
 <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com>
 <CAL6e_pdBDWBO796tfCnygj0e-c7S81O1y3hvZz3rgbMgxUobOg@mail.gmail.com>
 <9cade21c-5d92-d435-386f-6d854e6b6d55@gmail.com>
 <CAL6e_pc=Z03obL1U_+EY1t2EQ3Q7pmmcfU72tuO-hPzqqgPgig@mail.gmail.com>
 <aa76d6b7-dbb1-5275-09f6-a4450aeceeb2@gmail.com>
 <CAL6e_pfAtUAFRmm_2Ykn43jk-0mQn7f9FAt+CgHV4nFHT-PdPQ@mail.gmail.com>
 <609f2e30-3e9d-f317-e2b4-ba3fb7d20532@gmail.com>
 <CAL6e_pcL3DF1J1-+w0pw0CZ=Zm_BRfKtz=5jML_GcZBZFW1JVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Barnhill <0xeffeff@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:51707 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdJ2Ps3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 11:48:29 -0400
Received: by mail-pf0-f179.google.com with SMTP id n14so8808919pfh.8
        for <netdev@vger.kernel.org>; Sun, 29 Oct 2017 08:48:28 -0700 (PDT)
In-Reply-To: <CAL6e_pcL3DF1J1-+w0pw0CZ=Zm_BRfKtz=5jML_GcZBZFW1JVA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/17 8:43 PM, Jeff Barnhill wrote:
> ping v4 loopback...
> 
> jeff@VM2:~$ ip route list vrf myvrf
> 127.0.0.0/8 dev myvrf proto kernel scope link src 127.0.0.1
> 192.168.200.0/24 via 192.168.210.3 dev enp0s8
> 192.168.210.0/24 dev enp0s8 proto kernel scope link src 192.168.210.2
> 
> Lookups shown in perf script were for table 255.  Is it necessary to
> put the l3mdev table first?  If I re-order the tables, it starts
> working:

Yes, we advise moving the local table down to avoid false hits (e.g.,
duplicate addresses like this between the default VRF and another VRF).

I covered that and a few other things at OSS 2017. Latest VRF slides for
users:
  http://schd.ws/hosted_files/ossna2017/fe/vrf-tutorial-oss.pdf
