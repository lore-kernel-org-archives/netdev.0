From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Sun, 09 Jul 2017 21:40:43 +0100 (WEST)
Message-ID: <20170709.214043.1361767365552001158.davem@davemloft.net>
References: <20170708.113644.1272962770645338865.davem@davemloft.net>
        <CA+55aFzocFTX5JR9oG_5uKw-fT6OJUMkD71sypbec7JP=_qwpg@mail.gmail.com>
        <20170709191131.GB22224@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        herbert@gondor.apana.org.au
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170709191131.GB22224@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sun, 9 Jul 2017 15:11:31 -0400

> On (07/09/17 11:49), Linus Torvalds wrote:
>> 
>> On Sat, Jul 8, 2017 at 3:36 AM, David Miller <davem@davemloft.net> wrote:
>> >
>> > 8) Fix socket leak on accept() in RDS, from Sowmini Varadhan.  Also
>> >    add a WARN_ON() to sock_graft() so other protocol stacks don't trip
>> >    over this as well.
>> 
>> Hmm. This one triggers for me on both my desktop and laptop at bootup.
>> Bog-standard machines, running F25 and F24 respectively.
>> 
>> The warning doesn't seem particularly useful, although maybe that
>> "alg_accept()" gives people who know this code enough of a clue.
> 
> My initial question was whether sock_graft() should do a sock_put()
> before cutting loose the existing parent->sk and assigning a new
> parent->sk (https://www.spinics.net/lists/netdev/msg442191.html)
> 
> It look like PF_ALG sets up a ->sk in alg_create() (but this
> would get over-written in alg_accept()?) 
> 
> Cc'ing Herbert to see if this is expected behavior (and PF_ALG
> somehow does the right thing with the refcount for the ->sk
> set up in alg_create) in which case I suppose we should drop the 
> WARN_ON. 

I think we've found yet another socket leak, this time in
AF_ALG.
