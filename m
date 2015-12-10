From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 1/4] list: introduce list_is_first()
Date: Thu, 10 Dec 2015 08:35:04 -0700
Message-ID: <56699BA8.1010009@kernel.dk>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
 <566995EA.80509@kernel.dk> <20151210152357.GG29872@treble.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Geliang Tang <geliangtang@163.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Seth Jennings <sjenning@redhat.com>,
	Jiri Kosina <jikos@kernel.org>,
	Vojtech Pavlik <vojtech@suse.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	live-patching@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
To: Josh Poimboeuf <jpoimboe@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151210152357.GG29872@treble.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/10/2015 08:23 AM, Josh Poimboeuf wrote:
> On Thu, Dec 10, 2015 at 08:10:34AM -0700, Jens Axboe wrote:
>> On 12/10/2015 07:17 AM, Geliang Tang wrote:
>>> We already have list_is_last(), it makes sense to also add
>>> list_is_first() for consistency. This list utility function
>>> to check for first element in a list.
>>
>> Honestly, I think we already have way too many of these kind of helpers.
>> IMHO they don't really help, they hurt readability. You should know how the
>> list works anyway, and if you do, then it's a no-brainer what's first and
>> last. If you don't, then you are bound to screw up in other ways.
>>
>> Just my 2 cents.
>
> Personally I would disagree.  Something like:
>
>    if (list_is_first(&rq->queuelist, &nd->queue))
>
> is much more readable to me than:
>
>    if (rq->queuelist.prev == &nd->queue)

Both the function and your example are backwards, and hence a lot harder 
to comprehend than they should be. It'd be much clearer as:

     if (nd->queue.next == &rq->queuelist)

which is a lot easier to read. Nobody should open-code a 'is this the 
first entry in the list' by asking 'is the previous link to my node the 
head', asking 'is the next entry in the list X' makes a lot more sense. 
I'm assuming this happened because the list_is_last was just copied and 
modified, instead of thinking about this for a second.

> The first one takes no effort for me -- it's almost English.  While the
> second one takes me a few seconds (and some precious brain cycles) to
> decipher.
>
> Maybe whether it's readable depends on how many years you've been
> looking at the pattern.  But IMHO we shouldn't make "having x # of years
> staring at kernel code" a prerequisite for being able to read kernel
> code.

It's a balance, as we also should not make APIs out of everything. As I 
said, purely my opinion, but I think the is_last/is_first have jumped 
the shark.

-- 
Jens Axboe
