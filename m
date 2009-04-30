From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Thu, 30 Apr 2009 15:14:05 -0400
Message-ID: <49F9F87D.5060309@myri.com>
References: <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com> <20090428152047.GB7549@gondor.apana.org.au> <49F77134.9030907@myri.com> <49F85945.7030900@myri.com> <49F85BF1.1020501@cosmosbay.com> <49F861BF.7060403@myri.com> <49F87188.9000904@cosmosbay.com> <49F88E5A.8070908@myri.com> <49F95E9B.5020005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1854 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750981AbZD3TPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 15:15:16 -0400
In-Reply-To: <49F95E9B.5020005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
 >
 >
 > I wonder if you could try to enlarge 'struct page' by 8 bytes and 
redo a test...
 >
 > Here is a patch to combine two ideas. But it wont allow GRO to go 
much faster I guess :(

The patch seems to help both GRO and LRO a little with timestamps disabled,
but seems to hurt a little with them.  I don't pretend to understand why:

LRO:
87380  65536  65536    60.00      8279.36   8.10     77.55    0.160   1.535
LRO + patch:
87380  65536  65536    60.01      7897.51   7.45     74.92    0.155   1.554
LRO + timestamp disable:
87380  65536  65536    60.02      7753.55   8.01     74.06    0.169   1.565
LRO + patch + timestamp disable:
87380  65536  65536    60.01      7915.63   7.74     74.57    0.160   1.544

GRO:
87380  65536  65536    60.00      8053.19   7.86     85.47    0.160 1.739
GRO + patch
87380  65536  65536    60.00      7910.02   7.69     85.86    0.159   1.778
GRO + timestamp disable:
87380  65536  65536    60.02      7535.12   7.27     84.57    0.158 1.839
GRO + timestamp disable + patch
87380  65536  65536    60.02      7735.26   7.92     83.68    0.168   1.772

Drew
