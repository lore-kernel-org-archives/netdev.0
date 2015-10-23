From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: (unknown)
Date: Fri, 23 Oct 2015 14:10:25 +0200
Message-ID: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: linux-bluetooth@vger.kernel.org, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@ghostprotocols.net, al.drozdov@gmail.com,
	alexander.h.duyck@redhat.com, daniel@iogearbox.net,
	davem@davemloft.net, dmitry.tarnyagin@lockless.no,
	dwmw2@infradead.org, edumazet@google.com, eyal.birger@gmail.com,
	fw@strlen.de, gustavo@padovan.org, hannes@stressinduktion.org,
	herbert@gondor.apana.org.au, jiri@resnulli.us, jmorris@namei.org,
	johan.hedberg@gmail.com, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	marcel@holtmann.org, mst@redhat.com, pablo@netfilter.org,
	samuel@sortiz.org, tom@herbertland.com, viro@zeniv.linux.org.uk,
	willemb@google.com, yoshfuji@linux-ipv6.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Subject: 
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello

This patch series was begun by my finding that memcpy_[to|from]_msg have
a parameter len which is an int but used as size_t in whole functions.
Without blindly changing the parameter to size_t, I have tried to see if
anywhere in linux source code, someone give a negative argument with
the following (unfinished) coccinnelle patch.
virtual report
@@
type T;
signed T i;
@@
(
memcpy_from_msg
|
memcpy_to_msg
)
 (...,
- i)
+ (size_t)i)

With that I found many place where int variable is used to store unsigned values
and which could be set as size_t since there are used againt size_t
and/or given to functions that wait for size_t.
It permit also to found a bug in net/llc/af_llc.c where a size_t variable
stored error codes.

Regards
