From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 2/3] tipc: message reassembly
 using fragment chain
Date: Tue, 29 Oct 2013 09:56:56 +0800
Message-ID: <526F15E8.9020009@windriver.com>
References: <1382812863-23571-1-git-send-email-jon.maloy@ericsson.com>
	<1382812863-23571-3-git-send-email-jon.maloy@ericsson.com>
	<20131028.010737.400887499395331496.davem@davemloft.net>
	<526E3B49.9030506@donjonn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, David Miller <davem@davemloft.net>
To: Jon Maloy <maloy@donjonn.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <526E3B49.9030506@donjonn.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 10/28/2013 06:24 PM, Jon Maloy wrote:
> On 10/28/2013 01:07 AM, David Miller wrote:
>> From: Jon Maloy <jon.maloy@ericsson.com>
>> Date: Sat, 26 Oct 2013 14:41:02 -0400
>>
>>> +			int ret = tipc_link_recv_fragment(
>>> +					&node->bclink.reasm_head,
>>> +					&node->bclink.reasm_tail,
>>> +					&buf);
>> This is not the correct way to indent a function call that spans
>> multiple lines.  In such a situation the arguments that appear
>> on the second and subsequent lines must start at the first column
>> after the openning parenthesis of the function call.
>>
>> Like this:
>>
>> 	func(a, b, c,
>> 	     d, e, f);
>>
>> Please audit this in your entire set of patches and resubmit,
>> thanks.
> 
> Doing as David says here means that some lines will be >80 chars.
> This was the reason for the somewhat strange indentation.
> I tried to rename the function to tipc_link_rcv_fragm(), but one
> line was still too long. The problem we have goes deeper.
> 
> In Linus' coding style manual I read that the 80 char limit is a hard limit,
> a limit we violate in several places. One offender is that we have too
> many indentation levels, at least in tipc_recv_msg() and probably in
> some other places. This is sensitive code, that I don't feel for touching
> right now.  A more low hanging fruit is our local variable names:
> names such as l_ptr, n_ptr, b_ptr is exactly what Linus characterizes
> as "brain dead Hungarian style", and I never liked that naming anyway.
> For me l, n, and b is good enough as long as the context is clear.
> 
> But, doing so, at least in tipc_recv_msg(), would require another, separate,
> patch, and it would lead to style inconsistency.
> 
> In brief, I am at loss about to proceed here, and I am not going to submit
> this patch again until I have some feedback from somebody who can tell me
> what is the right thing to do. Maybe > 80 chars is fine for now?
> 

It's hard completely resolve the issue by simply changing variable
names. So in my opinion, this is not a simple code style problem any
more. As tipc_recv_msg() is too complex, it includes at least three
embedded loops so that it doesn't remain too much space for functions in
the most inner loop. This is the key point.

Therefore, the best method is to divide tipc_recv_msg() into several
smaller functions to simplify the current implementation. But it's not
an easy job. Actually I ever tried to do it, but I gave up lastly
because I did not find one perfect solution about how to divide it.

Regards,
Ying

> ///jon
> 
> 
> 
> 


------------------------------------------------------------------------------
Android is increasing in popularity, but the open development platform that
developers love is also attractive to malware creators. Download this white
paper to learn more about secure code signing practices that can help keep
Android apps secure.
http://pubads.g.doubleclick.net/gampad/clk?id=65839951&iu=/4140/ostg.clktrk
