From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack_sip: CSeq 0 is a valid CSeq
Date: Mon, 4 Jul 2016 19:43:45 +0800
Message-ID: <CAML_gOeiqhdtV7Q0X8PWCoj1VDsTcWUhsCYcmLhdTigoaY=3tQ@mail.gmail.com>
References: <20160701094833.B281E1A23A2@localhost.localdomain>
 <CAML_gOdB=SjFyXosSb4MtaEymsAGV3beQwQqZMyhbezy=yDgxQ@mail.gmail.com> <bb18da60-bd09-05e0-0244-49942abbd1bd@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bb18da60-bd09-05e0-0244-49942abbd1bd@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-07-04 14:14 GMT+08:00 Christophe Leroy <christophe.leroy@c-s.fr>:
>> I think there is no need to convert simple_strtoul to kstrtouint, add
>> a further check seems better?
>> Like this:
>>  -       if (!cseq) {
>> +       if (!cseq && *(*dptr + matchoff) != '0') {
>>
>
> And what about an invalid CSeq that would look like CSeq: 0abzk852 ?
> Should we check it is 0 + space instead ?

In this case, i.e. some stupid sip clients set CSeq to "0abzk852",
your patch will also fail to detect this "error".

Because for "Cseq", int (*match_len)(...) point to digits_len(see
struct sip_header ct_sip_hdrs definition).
So in this case match_len will just be setted to ONE (not
sizeof("0abzk852")-1), then cseq will be parsed
as 0 by  kstrtouint, not as an error.
