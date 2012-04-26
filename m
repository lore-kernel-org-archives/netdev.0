From: "Kyle Mestery (kmestery)" <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Thu, 26 Apr 2012 16:16:36 +0000
Message-ID: <6D8BC25C-993E-4187-A277-930DDE6AB9AD@cisco.com>
References: <20120423.161313.1582195533832554777.davem@davemloft.net>
	<CAEP_g=8EVOVgDaWnu3sd+qHxNZ7+ogjzBkuWvfVHNAqX2DRf=g@mail.gmail.com>
	<20120423.170817.1103719420692884446.davem@davemloft.net>
	<CAEP_g=-52GOr3LzbUB+97ftNQBZV=7NWXqfWN6GMfq5KmdO25A@mail.gmail.com>
	<20120423223255.GG580@verge.net.au>
	<CAEP_g=9p0TE59JbrS8QzHj4mEzc-5_hUDzmLRsRxLyUaFX+Z5Q@mail.gmail.com>
	<20120424022514.GB5357@verge.net.au>
	<807AC914-2F33-46C7-99DC-E2F8F0F97531@cisco.com>
	<20120425083925.GB6661@verge.net.au>
	<CAEP_g=8DmQ_-8+ZbATdVhNJKiDSr0HdUgB-+oaqwU1=SqqzXfQ@mail.gmail.com>
	<20120426071321.GA25781@verge.net.au>
	<CAEP_g=8VQizt5iUc_yR+PynMYpZgD4ep+o379JK8k-KCKMYgmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "<dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>" <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	"<shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>" <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=8VQizt5iUc_yR+PynMYpZgD4ep+o379JK8k-KCKMYgmg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Content-ID: <76EC6FA6D7AB70419443496876238EE6-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org


On Apr 26, 2012, at 11:13 AM, Jesse Gross wrote:

> On Thu, Apr 26, 2012 at 12:13 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> On Wed, Apr 25, 2012 at 10:17:25AM -0700, Jesse Gross wrote:
>>> On Wed, Apr 25, 2012 at 1:39 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>>>> 
>>>> Hi Kyle,
>>>> 
>>>> the component that is of most interest to me is enabling OVS to use in-tree
>>>> tunnelling code - as it seems that makes most sense for an implementation
>>>> of STT. I have taken a brief look over your vxlan work and it isn't clear
>>>> to me if it is moving towards being an in-tree implementation.  Moreover,
>>>> I'm a rather unclear on what changes need to be made to OVS in order for
>>>> in-tree tunneling to be used.
>>>> 
>>>> My recollection is that OVS did make use of in-tree tunnelling code
>>>> but this was removed in favour of the current implementation for various
>>>> reasons (performance being one IIRC). I gather that revisiting in-tree
>>>> tunnelling won't revisit the previous set of problems. But I'm unclear how.
>>>> 
>>>> Jesse, is it possible for you to describe that in a little detail
>>>> or point me to some information?
>>> 
>>> This was what I had originally written a while back, although it's
>>> more about OVS internally and less about how to connect to the in-tree
>>> code:
>>> http://openvswitch.org/pipermail/dev/2012-February/014779.html
>>> 
>>> In order to flexibly implement support for current and future tunnel
>>> protocols OVS needs to be able to get/set information about the outer
>>> tunnel header when processing the inner packet.  At the very least
>>> this is src/dst IP addresses and the key/ID/VNI/etc.  In the upstream
>>> tunnel implementations those are implicitly encoded in the device that
>>> sends or receives the packet.  However, this has a two problems:
>>> number of devices and ability to handle unknown values.  We addressed
>>> part of this problem by allowing the tunnel ID to be set and matched
>>> through the OVS flow table and an action.  In order to do this with
>>> the in-tree tunneling code, we obviously need a way of passing this
>>> information around since it would currently get lost as we pass
>>> through the Linux device layer.
>>> 
>>> The plan to deal with that is to add a function to the in-tree
>>> tunneling code that allows a skb to be encapsulated with specific
>>> parameters and conversely a hook to receive decapsulated packets along
>>> with header info.  This would make all of the kernel tunneling code
>>> common, while still giving OVS userspace the ability to implement
>>> essentially any type of tunneling policy.  In many ways, this is very
>>> similar to how vlans look in OVS today.
>>> 
>>> While it would be possible to implement the hook to use the in-tree
>>> tunnel code today without a lot of changes, we already know that we
>>> want to move away from port-based model in the OVS kernel module
>>> towards the flow model.  As we push this upstream the userspace/kernel
>>> API should be the correct one, so that's why these two things are tied
>>> together.
>> 
>> 
>> Thanks, that explanation along with Kyle's response helps a lot.
>> 
>> It seems to me that something I could help out with is the implementation
>> of the set_tunnel action which extents and replaces the tun_id action.
>> It seems that is a requirement for the scheme you describe above.
>> 
>> http://openvswitch.org/pipermail/dev/2012-April/016239.html
> 
> I agree that's probably the best place to start unless Kyle has some
> specific plans otherwise.

Simon and I chatted off-list, and this is indeed where we plan to start.
