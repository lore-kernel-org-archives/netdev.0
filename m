From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -master 1/2] bpf: update printing of generic
 xdp mode
Date: Sat, 13 May 2017 11:19:10 +0200
Message-ID: <5916CF8E.4000602@iogearbox.net>
References: <cover.1494635217.git.daniel@iogearbox.net> <3c90a0b9480c61746220636ed48320da53410b6f.1494635217.git.daniel@iogearbox.net> <d012ef18-8689-81ef-8f56-ef2b9c673b44@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55626 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbdEMJTN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 13 May 2017 05:19:13 -0400
In-Reply-To: <d012ef18-8689-81ef-8f56-ef2b9c673b44@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2017 11:01 AM, Sergei Shtylyov wrote:
> On 5/13/2017 3:32 AM, Daniel Borkmann wrote:
>
>> Follow-up to d67b9cd28c1d ("xdp: refine xdp api with regards to
>> generic xdp") in order to update the XDP dumping part.
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>  ip/iplink_xdp.c | 19 +++++++++++--------
>>  1 file changed, 11 insertions(+), 8 deletions(-)
>>
>> diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
>> index a1380ee..98503fa 100644
>> --- a/ip/iplink_xdp.c
>> +++ b/ip/iplink_xdp.c
>> @@ -79,17 +79,20 @@ int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic)
>>  void xdp_dump(FILE *fp, struct rtattr *xdp)
>>  {
>>      struct rtattr *tb[IFLA_XDP_MAX + 1];
>> -    __u32 flags = 0;
>> +    __u8 mode;
>>
>>      parse_rtattr_nested(tb, IFLA_XDP_MAX, xdp);
>>
>> -    if (!tb[IFLA_XDP_ATTACHED] ||
>> -        !rta_getattr_u8(tb[IFLA_XDP_ATTACHED]))
>> +    if (!tb[IFLA_XDP_ATTACHED])
>>          return;
>>
>> -    if (tb[IFLA_XDP_FLAGS])
>> -        flags = rta_getattr_u32(tb[IFLA_XDP_FLAGS]);
>> -
>> -    fprintf(fp, "xdp%s ",
>> -        flags & XDP_FLAGS_SKB_MODE ? "generic" : "");
>> +    mode = rta_getattr_u8(tb[IFLA_XDP_ATTACHED]);
>> +    if (mode == XDP_ATTACHED_NONE)
>> +        return;
>> +    else if (mode == XDP_ATTACHED_DRV)
>> +        fprintf(fp, "xdp ");
>> +    else if (mode == XDP_ATTACHED_SKB)
>> +        fprintf(fp, "xdpgeneric ");
>> +    else
>> +        fprintf(fp, "xdp[%u] ", mode);
>
>     This is asking to be a *switch* statement.

The code is fine as-is, thank you !
