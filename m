From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT net-next] Open vSwitch
Date: Mon, 13 Jan 2014 17:30:48 -0800
Message-ID: <CAEP_g=8nG6AHV9Y+5=48nPhkf5Oe=mG8EiyaKSqN4omnmGhv4A@mail.gmail.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
	<52CD657F.7080806@citrix.com>
	<CAEP_g=_pQpH--V+7GSrjGP2z=0TBD_37yXjzTdeKG+2OF3aRaw@mail.gmail.com>
	<52D42A9E.1030805@citrix.com> <52D4857C.7020902@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <52D4857C.7020902-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
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

On Mon, Jan 13, 2014 at 4:31 PM, Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org> wrote:
> On 13/01/14 18:04, Zoltan Kiss wrote:
>>
>> On 08/01/14 15:10, Jesse Gross wrote:
>>>
>>> On Wed, Jan 8, 2014 at 9:49 AM, Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
>>> wrote:
>>>>
>>>> Hi,
>>>>
>>>> I've tried the latest net-next on a Xenserver install with 1.9.3
>>>> userspace,
>>>> and it seems this patch series broke it (at least after reverting that
>>>> locally it works now). I haven't went too far yet checking what's the
>>>> problem, but it seems the xenbrX device doesn't really receive too much
>>>> of
>>>> the traffic coming through the NIC. Is it expected?
>>>
>>>
>>> What do you mean by doesn't receive too much traffic? What does it get?
>>>
>>
>> Sorry for the vague error description, now I had more time to look into
>> this. I think the problem boils down to this:
>>
>> Jan 13 17:55:07 localhost ovs-vswitchd:
>> 07890|netlink_socket|DBG|nl_sock_recv__ (Success): nl(len:274,
>> type=29(ovs_packet), flags=0, seq=0, pid=0,genl(cmd=1,version=1)
>> Jan 13 17:55:07 localhost ovs-vswitchd: 07891|netlink|DBG|attributes
>> followed by garbage
>> Jan 13 17:55:07 localhost ovs-vswitchd: 07892|dpif|WARN|system@xenbr0:
>> recv failed (Invalid argument)
>>
>> That's just keep repeating. I'm keep looking.
>
>
> Now I reverted these top 3 commits:
>
> ovs: make functions local
>
> openvswitch: Compute checksum in skb_gso_segment() if needed
> openvswitch: Use skb_zerocopy() for upcall
>
> And it works. I guess the last one causing the problem. Might be an
> important factor, I'm using 32 bit Dom0.

I think you're probably right. Thomas - can you take a look?

We shouldn't be doing any zerocopy in this situation but it looks to
me like we don't do any padding at all, even in situations where we
are copying the data.
