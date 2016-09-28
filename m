From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH v3 net-next] tcp: Change txhash on every SYN and RTO
 retransmit
Date: Wed, 28 Sep 2016 05:07:16 +0000
Message-ID: <D4109D86.1F361%brakmo@fb.com>
References: <20160927233123.2447232-1-brakmo@fb.com>
 <CAK6E8=dDXd9PFA=AojMOsTOXTm_KkczB2_4G3vPuQLC2Ni5QsQ@mail.gmail.com>
 <CADVnQykozyJ3nnHz956aXnT9c+cEqUmf0HMqSHjbKQXWiMoSTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
        "Eric Dumazet" <eric.dumazet@gmail.com>
To: Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55158 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751652AbcI1FHZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 01:07:25 -0400
In-Reply-To: <CADVnQykozyJ3nnHz956aXnT9c+cEqUmf0HMqSHjbKQXWiMoSTA@mail.gmail.com>
Content-Language: en-US
Content-ID: <4AE4E15BEE9AF24D9983B5D229A581E9@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neal and Yuchung, thank you for the feedback. I=B9ve submitted v4 with your
recommended changes.

Thanks,
Larry

On 9/27/16, 6:28 PM, "Neal Cardwell" <ncardwell@google.com> wrote:

>On Tue, Sep 27, 2016 at 8:18 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> On Tue, Sep 27, 2016 at 4:31 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>>> @@ -213,6 +215,8 @@ static int tcp_write_timeout(struct sock *sk)
>>>                         tcp_mtu_probing(icsk, sk);
>>>
>>>                         dst_negative_advice(sk);
>>> +               } else if (prandom_u32_max(100) <
>>>sysctl_tcp_rto_txhash_prob) {
>> The sysctl is not really needed but that's just my opinion.
>
>I agree that it sounds nice to simplify by not having a sysctl for
>this and always calling sk_rethink_txhash() here.
>
>neal
