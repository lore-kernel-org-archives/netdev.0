From: Minoru Usui <mi.usui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 07:38:51 +0900
Message-ID: <b10243b50905301538o2716855ag21fbc95b37c8da22@mail.gmail.com>
References: <20090529225929.GD2753@ami.dom.local>
	<20090530114506.GA3166@ami.dom.local>
	<1243684594.3966.89.camel@dogo.mojatatu.com>
	<20090530120750.GB3166@ami.dom.local>
	<1243686683.3966.117.camel@dogo.mojatatu.com>
	<20090530124554.GC3166@ami.dom.local>
	<1243688628.3966.126.camel@dogo.mojatatu.com>
	<20090530132047.GD3166@ami.dom.local>
	<1243690297.3966.135.camel@dogo.mojatatu.com>
	<20090530140006.GE3166@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090530140006.GE3166-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, jarek

2009/5/30 Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> On Sat, May 30, 2009 at 09:31:37AM -0400, jamal wrote:
>> On Sat, 2009-05-30 at 15:20 +0200, Jarek Poplawski wrote:
>>
>> > Yes it oopses in cls_cgroup_classify(). Here is the first report:
>> > http://permalink.gmane.org/gmane.linux.network/128593
>> >
>>
>> Oopsing in classify is after the fact though. It should not have been
>> linked to begin with (because wrong config was passed from user space).
>> As far as cls_group is concerned that is an illegitimate config - thats
>> why it failed it.
>>
>> What were you suggesting to change in cls_group to avoid this oops?
>
> I think checking the head (tp->root) for NULL like in cls_fw or
> cls_route should work.

I agree.
I think cls_cgroup should check head(tp->root) whether NULL or not
like other classifiers, too.

But I think it's problem adding/linking unconfigured tp, too.

>>
>> > We add/link unconfigured tp, but it could be destroyed later, so I
>> > wouldn't call this a memory leak.
>>
>> Indeed - call it "We add/link unconfigured tp".
>
> Anyway, it's worked for other classifiers like this for some time...

I'm sorry, I don't investigate well, so I don't understand where
unconfigured tp is destroyed, yet.
If you don't mind, could you tell me where it's destoryed?
