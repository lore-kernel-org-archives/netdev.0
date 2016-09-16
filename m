From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH next] sctp: make use of WORD_TRUNC macro
Date: Fri, 16 Sep 2016 09:51:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00FF62C@AcuExch.aculab.com>
References: <b40b1bd4adff2d389588d9a4710af0399ce68d1e.1473963064.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:54483 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbcIPJyQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 05:54:16 -0400
In-Reply-To: <b40b1bd4adff2d389588d9a4710af0399ce68d1e.1473963064.git.marcelo.leitner@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 15 September 2016 19:13
> No functional change. Just to avoid the usage of '&~3'.
...
> -	max_data = (asoc->pathmtu -
> -		sctp_sk(asoc->base.sk)->pf->af->net_header_len -
> -		sizeof(struct sctphdr) - sizeof(struct sctp_data_chunk)) & ~3;
> +	max_data = asoc->pathmtu -
> +		   sctp_sk(asoc->base.sk)->pf->af->net_header_len -
> +		   sizeof(struct sctphdr) - sizeof(struct sctp_data_chunk);
> +	max_data = WORD_TRUNC(max_data);

Hmmm....
Am I the only person who understands immediately what & ~3 does
but would have to grovel through the headers to find exactly what
WORD_TRUNC() does.

How big is a 'WORD' anyway??

	David
