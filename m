From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/3] net: sctp: Optimise the way 'sctp_arg_t'
 values are initialised
Date: Tue, 1 Jul 2014 13:14:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726AA43@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D17269789@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	Network Development <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51259 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751513AbaGANPf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 09:15:35 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02893-09 for <netdev@vger.kernel.org>;
 Tue,  1 Jul 2014 14:15:26 +0100 (BST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17269789@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight
> Even if memset() is inlined (as on x86) using it to zero the union
> generates a memory word write of zero, followed by a write of the
> smaller field, and then a read of the word.
> As well as being a lot of instructions the sequence is unlikely to
> be optimised by the store-load forward hardware so will be slow.
> 
> Instead allocate a field of the union that is the same size as the
> entire union and write a zero value to it. The compiler will then
> generate the required value in a register.
> 
> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
>  include/net/sctp/command.h | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
> index 020eb95..5fcd1a7 100644
> --- a/include/net/sctp/command.h
> +++ b/include/net/sctp/command.h
...
> @@ -212,7 +213,6 @@ typedef struct {
>   */
>  static inline int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
>  {
> -	memset(seq, 0, sizeof(sctp_cmd_seq_t));
>  	return 1;		/* We always succeed.  */
>  }

I've realised that this version of this chunk leaves seq->next_free_slot
and seq->next_cmd uninitialized (they need to be zero).
The next patch in the series contains different initialisers - which are correct.
I guess this needs fixing for 'git bisect' ?

	David
