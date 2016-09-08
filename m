From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Thu, 8 Sep 2016 11:48:50 -0700
Message-ID: <a36a195c-a796-847e-3770-e5a79ce2638b@hpe.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Eric Dumazet <eric.dumazet@gmail.com>,
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
To: Tom Herbert <tom@herbertland.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hpe.com ([15.241.140.73]:41246 "EHLO
        g4t3427.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759043AbcIHSsy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 14:48:54 -0400
In-Reply-To: <CALx6S353F0HiqF8JNZwkcAR_dSt1=EauDj1U57MqOtpi4_SbdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2016 11:16 AM, Tom Herbert wrote:
> On Thu, Sep 8, 2016 at 10:19 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
>> On Thu, 8 Sep 2016 09:26:03 -0700
>> Tom Herbert <tom@herbertland.com> wrote:
>>> Shouldn't qdisc bulk size be based on the BQL limit? What is the
>>> simple algorithm to apply to in-flight packets?
>>
>> Maybe the algorithm is not so simple, and we likely also have to take
>> BQL bytes into account.
>>
>> The reason for wanting packets-in-flight is because we are attacking a
>> transaction cost.  The tailptr/doorbell cost around 70ns.  (Based on
>> data in this patch desc, 4.9Mpps -> 7.5Mpps (1/4.90-1/7.5)*1000 =
>> 70.74). The 10G wirespeed small packets budget is 67.2ns, this with
>> fixed overhead per packet of 70ns we can never reach 10G wirespeed.
>>
> But you should be able to do this with BQL and it is more accurate.
> BQL tells how many bytes need to be sent and that can be used to
> create a bulk of packets to send with one doorbell.

With small packets and the "default" ring size for this NIC/driver 
combination, is the BQL large enough that the ring fills before one hits 
the BQL?

rick jones
