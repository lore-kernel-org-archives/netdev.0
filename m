From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Thu, 08 Sep 2016 11:52:59 -0700
Message-ID: <1473360779.18970.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
         <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
         <1473259302.10725.31.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8G1SvmHKLm2Oqn3v8FUAOjScS+=tsbOaixkPUY4JFDPQ@mail.gmail.com>
         <1473262379.10725.42.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9iVpS2qH5Ryc_DtEjrQMhcKD+qrLrGn=vet=_9N8eXPw@mail.gmail.com>
         <20160907202234.55e18ef3@redhat.com> <57D0D3EA.1090004@gmail.com>
         <CALx6S34vqa+13c_4m0CKqL_6U+37DQ15T=WRAdUZNL3iYo1J0g@mail.gmail.com>
         <20160908071119.776cce56@redhat.com>
         <CALx6S35B4gp80AWPBvUv2hEGAMc8Hs2ErjAPOB8SU=SgYoUp=Q@mail.gmail.com>
         <20160908191914.197ce7ec@redhat.com>
         <CALx6S353F0HiqF8JNZwkcAR_dSt1=EauDj1U57MqOtpi4_SbdA@mail.gmail.com>
         <a36a195c-a796-847e-3770-e5a79ce2638b@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Achiad Shochat <achiad@mellanox.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34485 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932787AbcIHSxC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 14:53:02 -0400
Received: by mail-pf0-f169.google.com with SMTP id p64so20916386pfb.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 11:53:02 -0700 (PDT)
In-Reply-To: <a36a195c-a796-847e-3770-e5a79ce2638b@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 11:48 -0700, Rick Jones wrote:

> With small packets and the "default" ring size for this NIC/driver 
> combination, is the BQL large enough that the ring fills before one hits 
> the BQL?

It depends on how TX completion (NAPI handler) is implemented in the
driver.

Say how many packets can be dequeued by each invocation.

Drivers have a lot of variations there.
