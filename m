From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] netlink: align attributes on 64-bits
Date: Fri, 14 Dec 2012 17:04:01 +0100
Message-ID: <50CB4DF1.5020903@6wind.com>
References: <20121211184013.GD27746@casper.infradead.org>  <1355491002-3931-1-git-send-email-nicolas.dichtel@6wind.com> <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tgraf@suug.ch, netdev@vger.kernel.org, davem@davemloft.net,
	David.Laight@ACULAB.COM
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:49535 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756252Ab2LNQEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 11:04:04 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1362406eaa.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 08:04:03 -0800 (PST)
In-Reply-To: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/12/2012 16:49, Ben Hutchings a =C3=A9crit :
> On Fri, 2012-12-14 at 14:16 +0100, Nicolas Dichtel wrote:
>> On 64 bits arch, we must ensure that attributes are always aligned o=
n 64-bits
>> boundary. We do that by adding attributes of type 0, size 4 (alignme=
nt on
>> 32-bits is already done) when needed. Attribute type 0 should be ava=
ilable and
>> unused in all netlink families.
> [...]
>> --- a/lib/nlattr.c
>> +++ b/lib/nlattr.c
>> @@ -450,9 +450,18 @@ EXPORT_SYMBOL(__nla_put_nohdr);
>>    */
>>   int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const =
void *data)
>>   {
>> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
>> +	int align =3D IS_ALIGNED((unsigned long)skb_tail_pointer(skb), siz=
eof(void *)) ? 0 : 4;
>
> The assumption here is that nothing needs to be aligned to a greater
> width than that of a pointer.  However, for most 32-bit architectures
> (i386 being an exception) the C ABI requires 64-bit alignment for 64-=
bit
> types.  There may be cases where a mostly 32-bit processor really
> requires 64-bit alignment, e.g. to load or save a pair of registers.
Ok, I will wait other comments to send a v2 (which will align these att=
ributes=20
for all arch).

Nicolas
