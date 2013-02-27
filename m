From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: LSM stacking and the network access controls
Date: Wed, 27 Feb 2013 08:51:50 -0800
Message-ID: <512E39A6.1000804@schaufler-ca.com>
References: <1803195.0cVPJuGAEx@sifl> <1495594.zrMMDNjium@sifl> <512D415F.7050205@schaufler-ca.com> <9802466.KDjcZ61qbX@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Andy King <acking@vmware.com>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <9802466.KDjcZ61qbX@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/27/2013 8:43 AM, Paul Moore wrote:
> On Tuesday, February 26, 2013 03:12:31 PM Casey Schaufler wrote:
>> On 2/26/2013 1:21 PM, Paul Moore wrote:
>>> On Monday, February 25, 2013 03:06:14 PM Casey Schaufler wrote:
>>>> The set of LSMs, the order they are invoked, which LSM
>>>> uses /proc/.../attr/current and which LSM uses Netlabel,
>>>> XFRM and secmark are all determined by Kconfig. You can
>>>> specify a limited set of LSMs using security= at boot,
>>>> but not the networking configuration.
>>> That's unfortunate.  I'm _really_ not in favor of that, I would much
>>> rather see the non-shared LSM functionality assigned at the same time as
>>> the stacking order.  I'm not sure I'd NACK the current approach, or even\
>>> if anyone would care that I did, but that is how I'm currently leaning
>>> with this split (build vs runtime) selection.
>> I'm not against that approach. How would you see it working?
>>
>> The distro compiles in all the LSMs.
>> They specify that SELinux gets xfrm and secmark.
>> They specify the Smack gets Netlabel.
>> They tell (the new and improved) AppArmor to eschew networking.
>> They specify a boot order of "selinux,smack,apparmor,yama"
>> (They left off tomoyo for tax purposes).
>>
>> On the boot line, the user types "security=apparmor".
>>
>> What should happen?
> Okay, I misunderstood what was specified at boot time; I thought the stacking 
> order could be defined at boot but based on your example I'm guessing the 
> stacking order is defined at compile time and you can only enable/disable LSMs 
> at boot?

Well, no. It looks as if I gave a poor example.

	"security=apparmor,tomoyo,selinux"

is legitimate and indicates that AppArmor goes first,
then TOMOYO, then SELinux. No LSM gets NetLabel because
that was allocated to Smack. SELinux gets XFRM and secmark.
 

>>>> Tetsuo is lobbying for loadable security modules. I am
>>>> doing my best to leave everything in a state where some
>>>> soul braver than I might pick that up after I'm done.
>>>> I do not have any intention of supporting on the fly
>>>> or heuristically determined networking.
>>> Well, if that is the case I think the first-come-first-served approach to
>>> the non-shared functionality probably makes the most sense.  I understand
>>> why it might not be ideal in ever situation but it is predictable.
>> Would you have the same opinion if SELinux were last, instead of first?
> Yes.
>
> In fact, considering the example above, and also assuming I'm understanding it 
> correctly, I think I am more in favor of the first-come-first-served approach 
> since you can enable/disable LSMs at boot.  Imagine if you gave one LSM all 
> the non-shared functionality but disabled it at boot in favor of another LSM 
> which could make use of some of this functionality but was denied due to the 
> compile time option.  This seems much more useful to me.
>
>>>>>> I'm trying not to make too many architectural changes to the
>>>>>> code around the LSM mechanism itself. I don't see that as cost
>>>>>> effective or likely to be popular. If the implication of that is
>>>>>> that there are certain configurations that are unsupportable but
>>>>>> that have plausible alternatives I think it will do for phase I.
>>>>> That statement is vague enough that I can't really say yes or no to it,
>>>>> but I will stick by my previous comments about the network access
>>>>> controls.
>>>> Ah. I want to create a useful system. I want to create it
>>>> reasonably short order. I am willing to forgo supporting
>>>> some configuration options to reduce the project time. In
>>>> particular, I hope to avoid mucking up other people's code
>>>> as that is a sure fire way to bog a project down.
>>> Usefulness is paramount of course
>> Agreed
>>
>>> and quickness is nice,
>> If it drags on too long the boss gets cranky. And "labelled" NFSv4.2
>> gets done. And the list macros get reworked. And ....
>>
>>> but I do think it takes a back seat to "the right solution".
>> If I had two years and didn't have to worry about anyone else's
>> changes and weren't beholden to retaining some of the past's more
>> interesting design choices I'd be more concerned about "right" than
>> "good".
>>
>>> We're all going to have to live with this f-o-r-e-v-e-r,
>> Assuming it gets adopted. It will have to be good enough for that.
>> There is no guarantee on that.
>>
>>> or at least what will surely seem like it, so I'd much rather we take the
>>> time to make sure we beat out as much ugly as we can before it is merged.
>> I'm with you there. I just hope the ugly hasn't been lifting weights.
> February is "fitness month".


