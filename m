From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: h323: bug in parsing of ASN1 SEQOF field
Date: Mon, 04 Apr 2011 15:24:19 +0200
Message-ID: <4D99C683.5070000@trash.net>
References: <1300794929-1541-1-git-send-email-dsterba@suse.cz> <20110322.193349.102533280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: dsterba@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110322.193349.102533280.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.03.2011 03:33, David Miller wrote:
> From: David Sterba <dsterba@suse.cz>
> Date: Tue, 22 Mar 2011 12:55:29 +0100
> 
>> Static analyzer of clang found a dead store which appears to be a bug in
>> reading count of items in SEQOF field, only the lower byte of word is
>> stored. This may lead to corrupted read and communication shutdown.
>>
>> The bug has been in the module since it's first inclusion into linux
>> kernel.
>>
>> Signed-off-by: David Sterba <dsterba@suse.cz>
> 
> Please send netfilter patches to the listed netfilter maintainer
> and appropriate mailing lists.  I've added them to the CC:
> 
> Otherwise your patch will not be looked at by the right people.
> 
>> CC: David Miller <davem@davemloft.net>
>> CC: netdev@vger.kernel.org
>> CC: stable@kernel.org
>> ---
>>  net/netfilter/nf_conntrack_h323_asn1.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
>> index 8678823..bcd5ed6 100644
>> --- a/net/netfilter/nf_conntrack_h323_asn1.c
>> +++ b/net/netfilter/nf_conntrack_h323_asn1.c
>> @@ -631,7 +631,7 @@ static int decode_seqof(bitstr_t *bs, const struct field_t *f,
>>  		CHECK_BOUND(bs, 2);
>>  		count = *bs->cur++;
>>  		count <<= 8;
>> -		count = *bs->cur++;
>> +		count += *bs->cur++;
>>  		break;

This looks correct to me. The problem is without practical consequence
though, the largest amount of sequence-of members we parse is 30.

Applied, thanks.
