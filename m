From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Sat, 15 Nov 2014 18:37:26 -0800
Message-ID: <7DA2F716-1E87-4AC8-A18F-CE5BFB6E6F81@joshtriplett.org>
References: <20141116022227.GA24541@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:58487 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755038AbaKPChk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 21:37:40 -0500
In-Reply-To: <20141116022227.GA24541@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On November 15, 2014 6:22:27 PM PST, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>Josh Triplett <josh@joshtriplett.org> wrote:
>>
>> - Set up the new empty table with the new set of hash parameters.
>> - synchronize_rcu().  Readers will now search both old and new
>tables.
>> - Peel nodes off the ends of the old hash table and add them to the
>new
>
>We currently use a singly linked list in rhashtable.  Peeling nodes
>off the end would mean upgrading to a doubly linked list, which is
>no different than keeping two lists in terms of cache footprint, no?

No, since each pass just handles one set of nodes from each bucket anyway, you can just do a bit more work in the rehasher instead.
