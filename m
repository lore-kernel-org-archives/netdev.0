From: MuraliRaja Muniraju <muralira@google.com>
Subject: Re: [PATCH v3] net-netlink: Add a new attribute to expose TOS values
 via netlink
Date: Tue, 11 Oct 2011 21:16:44 -0700
Message-ID: <CAP3iWTQXHwzw-qUYVfT--uNv4pNZnu0ROJnF7B1VLeZBbrfdqw@mail.gmail.com>
References: <20111010145206.6f7e9ee2@nehalam.linuxnetplumber.net>
	<1318382887-31824-1-git-send-email-muralira@google.com>
	<1318387734.3686.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318387734.3686.2.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric,
     I think it would be useful to expose the values this way.
     I shall make the changes to add TCLASS for ipv6 in the description=
=2E

     Regarding the TIME_WAIT state, I think it would be better of not
exposing the values because there would hardly be anything to transmit
during this time.

Thanks,
Murali

On Tue, Oct 11, 2011 at 7:48 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 11 octobre 2011 =E0 18:28 -0700, Muraliraja Muniraju a =E9cr=
it :
>> From: Murali Raja <muralira@google.com>
>>
>> This patch exposes the tos value for the TCP sockets when the TOS fl=
ag
>> is requested in the ext_flags for the inet_diag request. This would =
mainly be
>> used to expose TOS values for both for TCP and UDP sockets. Currentl=
y it is
>> supported for TCP. When netlink support for UDP would be added the s=
upport
>> to expose the TOS values would alse be done.
>>
>
> You could mention TCLASS support for IPv6
>
>> Signed-off-by: Murali Raja <muralira@google.com>
>> ---
>> Changelog since v2:
>> - Adding support for IPV6 class and using right API's
>> Changelog since v1:
>> - Removing reserved field
>>
>> =A0include/linux/inet_diag.h | =A0 =A09 ++++++++-
>> =A0net/ipv4/inet_diag.c =A0 =A0 =A0| =A0 =A05 +++++
>> =A02 files changed, 13 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
>> index bc8c490..e36093d 100644
>> --- a/include/linux/inet_diag.h
>> +++ b/include/linux/inet_diag.h
>> @@ -97,9 +97,10 @@ enum {
>> =A0 =A0 =A0 INET_DIAG_INFO,
>> =A0 =A0 =A0 INET_DIAG_VEGASINFO,
>> =A0 =A0 =A0 INET_DIAG_CONG,
>> + =A0 =A0 INET_DIAG_TOS,
>> =A0};
>>
>> -#define INET_DIAG_MAX INET_DIAG_CONG
>> +#define INET_DIAG_MAX INET_DIAG_TOS
>>
>>
>> =A0/* INET_DIAG_MEM */
>> @@ -120,6 +121,12 @@ struct tcpvegas_info {
>> =A0 =A0 =A0 __u32 =A0 tcpv_minrtt;
>> =A0};
>>
>> +/* INET_DIAG_TOS */
>> +
>> +struct inet_diag_tos {
>> + =A0 =A0 __u8 =A0 =A0idiag_tos;
>> +};
>
> Are you sure its still needed ?
>
> I am now wondering what is done in TIME_WAIT state.
>
>
>



--=20
Thanks,
Murali
