From: sandr8 <sandr8@crocetta.org>
Subject: Re: [PATCH] bio_uncopy_user mem leak
Date: Fri, 20 Aug 2004 22:28:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41265EF2.3000703@crocetta.org>
References: <1092909598.8364.5.camel@localhost>	<412489E5.7000806@kolivas.org>	<1092923494.12138.1667.camel@watt.suse.com>	<20040819195521.GC12363@tpkurt.garloff.de>	<41256DC9.7070500@kolivas.org> <20040819233155.68c1411e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org,
        kernel@gentoo.org, lartc@mailman.ds9a.nl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040819233155.68c1411e.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

>Con Kolivas <kernel@kolivas.org> wrote:
>
>Uh, I guess that depends on how rested Linus feels when he returns.  I
>think there's a fairly significant networking fix too.  As I said: we'll see
>
is that the one related to the qdisc private data alignment? if not, 
that one would be a urgent one too imho...
i got many oops from the ext3 commit and this because all of the 
schedulers in the 2.6.8 and 2.6.8.1 traffic control suite are accessing 
data at slightly wrong positions.
this because if any discipline different from pfifo fast is used, the 
kmalloc()ed memory is aligned in the old way, but then it is used in the 
new one.
the results could be catastrophic whenever the accessed data is a 
pointer and the memory referenced is written to. :-\

Alessandro Salvatori
