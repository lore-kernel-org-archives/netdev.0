From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.56] datapath: Add basic MPLS support to
	kernel
Date: Fri, 25 Apr 2014 12:57:20 -0700
Message-ID: <CAEP_g=8y=jXukP=a2xyk4XMTrBLYWPQOgbTO_h8LE_mVMB9tFQ@mail.gmail.com>
References: <20140424232441.GA6282@verge.net.au>
 <20140425080639.DDFA371E74@kuma.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ravi kerur <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140425080639.DDFA371E74-0CV7wKnmZOB82hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, Apr 25, 2014 at 1:06 AM, YAMAMOTO Takashi
<yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
>> On Thu, Apr 24, 2014 at 05:57:29PM +0900, YAMAMOTO Takashi wrote:
>>> hi,
>>>
>>> > + * Due to the sample action there may be multiple possible eth types.
>>> > + * In order to correctly validate actions all possible types are tracked
>>> > + * and verified. This is done using struct eth_types.
>>>
>>> is there any real-world use cases of these actions inside a sample?
>>> otherwise, how about just rejecting such combinations?
>>> it doesn't seem to worth the code complexity to me.
>>> (sorry if it has been already discussed.  it's the first time for me
>>> to seriously read this long-lived patch.)
>>
>> Good point, the code is rather complex.
>>
>> My understanding is that it comes into effect in the case
>> of sflow or ipfix being configured on the bridge. I tend
>> to think these are real-world use-cases, though that thinking
>> is by no means fixed.
>>
>> My reading of the code is that in the case of sflow and ipfix a single
>> sample rule appears at the beginning of the flow. And that it may be
>> possible to replace the code that you are referring to with something
>> simpler to handle these cases.
>
> it seems that they put only a userland action inside a sample.
> it's what i expected from its name "sample".

Yes, that's the only current use case. In theory, this could be used
more generally although nothing has come up yet.

In retrospect, I regret the design of the sample action - not the part
that allows it to handle different actions but the fact that the
results can affect things outside of the sample action list. I think
that if we had made it more like a subroutine then that would have
retained all of the functionality but none of the complexity here.
Perhaps if we can find a clean way to restructure it without breaking
compatibility then that would simplify the validation here.

>>
>> My understanding is that the code you are referring to also comes into
>> effect when a sample action (a Nicira extension) is used directly in a
>> rule.  I am less sure that this is a real-world case but the complex logic
>> you are referring to should to handle this use-case.
>
> probably nicira folks can clarify?

It's the same set of use cases, just extending it to OpenFlow to
enable building sampling into different situations.
