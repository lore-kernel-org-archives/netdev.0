From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ: Reordering?
Date: Sat, 07 May 2005 00:46:28 +0200
Message-ID: <427BF3C4.1030105@trash.net>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427BEAAE.409@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Asim Shankar wrote:
> 
>>Should complete rehashing take place in sfq_perturbation(), or am I
>>missing something? (I was looking at 2.6.9 and also took a cursory
>>glance at 2.6.11 on lxr.linux.no)
> 
> 
> I think we should rehash. Can you send a patch?

Hmm wait, this is not so easy. We can't rehash by going over
the buckets one by one. If we do so and we have a new clash of
two flows previously contained in different buckets the packets
will afterwards be sorted by flow in their new bucket. To retain
fairness we need to iterate over all buckets containing packets
and rehash them one packet per a bucket at a time. But this means
we need lots of temporary storage to store the queues while
rehashing. Can anyone thing of a better solution?
