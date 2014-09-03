From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch net-next 01/13] openvswitch: split flow
 structures into ovs specific and generic ones
Date: Wed, 3 Sep 2014 14:59:17 -0700
Message-ID: <CALnjE+qUqSK7kHSi5BZuA0hzFjMcZ8TCTd9JRG1PPmMfDmAQOA@mail.gmail.com>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <1409736300-12303-2-git-send-email-jiri@resnulli.us>
 <CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw@mail.gmail.com>
 <54078694.5040104@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "ryazanov.s.a" <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jasowang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "john.r.fastabend" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "neil.jerram" <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 andy <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 nbd <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, "f.fainelli" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Rony Efraim <ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "jeffrey.t.kirsher" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 buytenh <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 roopa <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, aviadr <aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, vyasevic <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 nhorman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <54078694.5040104-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
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

On Wed, Sep 3, 2014 at 2:22 PM, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org> wrote:
> On 09/03/14 14:41, Pravin Shelar wrote:
>>
>> On Wed, Sep 3, 2014 at 2:24 AM, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org> wrote:
>
>
>> HW offload API should be separate from OVS module.
>
>
> The above part i agree with. Infact it is very odd that it seems
> hard to get this point across ;->
>
>
>> This has following
>> advantages.
>> 1. It can be managed by OVS userspace vswitchd process which has much
>> better context to setup hardware flow table. Once we add capabilities
>> for swdev, it is much more easier for vswitchd process to choose
>> correct (hw or sw) flow table for given flow.
>
>
> This i disagree with.
> The desire is to have existing user tools to work with offloads.
> When necessary, we then create new tools.
> Existing tools may need to be taught to do selectively do
> hardware vs software offload. We have a precedence with
> bridging code which selectively offloads to hardware using iproute2.
>
Both of us are saying same thing.
What I meant was for OVS use-case, where OVS wants to use offload for
switching flows, vswitchd userspace process can program HW offload
using kernel HW offload APIs directly from userspace, rather than
going through OVS kernel module. If user wants to use some other tool,
then the tool can use same kernel HW offload APIs.

>
>> 2. Other application that wants to use HW offload does not have
>> dependency on OVS kernel module.
>
>
> Or on OF for that matter.
>
>
>> 3. Hardware and software datapath remains separate, these two
>> components has no dependency on each other, both can be developed
>> independent of each other.
>>
>
> The basic definition of "offload" implies dependency;-> So,
> I strongly disagree. You may need to go backwards and look at
> views expressed on this (other than emails - theres slideware).
>

I was referring to code dependency in kernel. For example ovs flow-key
structure used. This complicates OVS internal structure which needs to
be shared plus OVS might need to extend interface for configuring HW
match or action that does not exist in OVS software datapath.

I agree these two components are related and that dependency can be
handled from userspace.
