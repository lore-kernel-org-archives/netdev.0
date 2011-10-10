From: MuraliRaja Muniraju <muralira@google.com>
Subject: Re: [PATCH v2] net-netlink: Add a new attribute to expose TOS values
 via netlink
Date: Mon, 10 Oct 2011 14:29:36 -0700
Message-ID: <CAP3iWTQ-7sNWMNazrmA1ZbNRATyd=MzKKsVtCHQ2_4dYboG=jg@mail.gmail.com>
References: <20111010130713.6df8bfe4@nehalam.linuxnetplumber.net>
	<1318278745-27734-1-git-send-email-muralira@google.com>
	<20111010140957.69f10b06@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller\"" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:19331 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab1JJV3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 17:29:39 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p9ALTcXY012144
	for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 14:29:38 -0700
Received: from ywm13 (ywm13.prod.google.com [10.192.13.13])
	by hpaq7.eem.corp.google.com with ESMTP id p9ALLAlH015238
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 14:29:37 -0700
Received: by ywm13 with SMTP id 13so8959886ywm.5
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 14:29:36 -0700 (PDT)
In-Reply-To: <20111010140957.69f10b06@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,
            Regarding the only field in the structure.

            -- I thought that adding it as a attribute and exposing it
via a extension instead of modifying the inet_diag_sockid structure.
This is to make sure that older binaries will not have issues with the
later kernel. Do you have any alternate suggestions.

            This change has been done keeping IPV4 in mind. I do not
see the V6 sockets exposed thought netlink. Please correct me if I am
reading it wrong.

Thanks,
Murali

On Mon, Oct 10, 2011 at 2:09 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 10 Oct 2011 13:32:25 -0700
> Muraliraja Muniraju <muralira@google.com> wrote:
>
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
>> Signed-off-by: Murali Raja <muralira@google.com>
>> ---
>> Changelog since v1:
>> - Removing the reserved field.
>>
>> =A0include/linux/inet_diag.h | =A0 =A09 ++++++++-
>> =A0net/ipv4/inet_diag.c =A0 =A0 =A0| =A0 =A07 +++++++
>> =A02 files changed, 15 insertions(+), 1 deletions(-)
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
> I think the idea is a good one, and useful, but want to make the
> ABI right.
> With only one entry, this doesn't need to be wrapped in a structure.
>
> Also does this work for IPv6 (Transport class) as well?
>
>



--=20
Thanks,
Murali
