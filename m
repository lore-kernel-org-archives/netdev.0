From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 4/4] fib_trie: Remove leaf_info
Date: Wed, 25 Feb 2015 16:16:41 -0800
Message-ID: <54EE65E9.9010302@gmail.com>
References: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20> <20150225190625.1747.49993.stgit@ahduyck-vm-fedora20> <alpine.LFD.2.11.1502252341500.2970@ja.home.ssi.bg> <54EE560E.8050504@redhat.com> <alpine.LFD.2.11.1502260124420.27068@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:42936 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbbBZAQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 19:16:43 -0500
Received: by pdbfp1 with SMTP id fp1so8598273pdb.9
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 16:16:42 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1502260124420.27068@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2015 04:06 PM, Julian Anastasov wrote:
> 	Hello,
>
> On Wed, 25 Feb 2015, Alexander Duyck wrote:
>
>>> 	If there is some fa in list with higher fa_slen
>>> fib_find_alias will always stop the loop and come with
>>> fa != NULL, so above 'if...break' is not needed, we are
>>> always going to add at tail when fa is NULL.
>> Actually fib_find_alias will return NULL in the case that there was a hole in
>> which the suffix length does not exist.
>>
>> So for example if we have a suffix length of 8 and one of 10 and we are adding
>> a suffix length of 9 then fib_find_alias will return NULL and we need to walk
>> though the list and find the hole we are supposed to drop the suffix in.
> 	I missed the fact that we return NULL instead of fa.
> I thought, it would be more consistent with the old logic
> to return a stop position. And we avoid walking the list
> again. But in practice we should not see many entries here,
> right?

Most users should have a pretty shallow list here.  In the case of BGP
routes there might be more entries per slen but the odds of encountering
a NULL in that case should be pretty low.

>> Why are you showing me an example with a 32b int when I am using a long?  For
>> x86 a 32b shift on a 32b value is undefined so we need to compare the suffix
>> length to the KEYLENGTH.  For 64b a long value can be shifted up to 63 bits
>> and still be a defined value.  That is why I use "1ul" as the value being
>> shifted and then also perform the check for KEYLENGTH vs BITS_PER_LONG in
>> order to determine if I still need the check for fa_slen != KEYLENGTH.
> 	I see, so, on 64-bit platform we avoid the
> KEYLENGTH check... OK, that is better.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

Yes, the BIT_PER_LONG check will be broken down to either 0 or 1 by the
complier so it will be stripped out in the resulting assembler.

- Alex
