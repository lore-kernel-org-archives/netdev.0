From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH nf 1/1] netfilter: h323,sip: Fix possible dead loop in
 nat_rtp_rtcp and nf_nat_sdp_media
Date: Thu, 2 Mar 2017 18:18:44 +0800
Message-ID: <CA+6hz4qO2Le_DCyuFt9zGnq2+TcR_GaDxXvSN_=1KOXYZti+iQ@mail.gmail.com>
References: <1488441420-25537-1-git-send-email-fgao@ikuai8.com> <CAML_gOfLQq7Q=E+oHrXuXz=uFFMyc0rQXxGO_RTi5hXJ3AaRuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        David Miller <davem@davemloft.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAML_gOfLQq7Q=E+oHrXuXz=uFFMyc0rQXxGO_RTi5hXJ3AaRuw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Liping,

On Thu, Mar 2, 2017 at 4:50 PM, Liping Zhang <zlpnobody@gmail.com> wrote:
> Hi,
>
> 2017-03-02 15:57 GMT+08:00  <fgao@ikuai8.com>:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> When h323 and sip try to insert expect nodes, they would increase
>> the port by 2 for loop, and the loop condition is that "port != 0".
>> So when the start port is odd number, port never increases to zero.
>
> This seems will never happen, since the RTP port has been ensured to
> be even.
>
> For example, at expect_rtp_rtcp():
>    ...
>    /* RTP port is even */
>    rtp_port = port & ~htons(1);
>    rtcp_port = port | htons(1);
>
> And at set_expected_rtp_rtcp():
>    ...
>    base_port = ntohs(tuple.dst.u.udp.port) & ~1;
>    rtp_port = htons(base_port);

Thanks your point, I actually did not attention these codes you mentioned.
But I checked the other codes, I think the dangerous may exist.

The expect class is NF_CT_EXPECT_CLASS_DEFAULT, and proto is
IPPROTO_UDP at the function "expect_rtp_rtcp",
And it makes sure the port is even number.

But look at the process_gcf, the port is got from the packet data at
function get_h225_addr.
So it may be odd number.
It also would add one expect node whose class is
NF_CT_EXPECT_CLASS_DEFAULT, and proto is IPPROTO_UDP.

BTW, the loop in nat_rtp_rtcp and nat_rtp_rtcp depend on one potential
condition which is protected by other functions.
It doesn't seem a good style.

Regards
Feng


