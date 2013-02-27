From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: LSM stacking and the network access controls
Date: Wed, 27 Feb 2013 09:40:12 -0800
Message-ID: <512E44FC.2080004@schaufler-ca.com>
References: <1803195.0cVPJuGAEx@sifl> <9802466.KDjcZ61qbX@sifl> <512E39A6.1000804@schaufler-ca.com> <7528811.sQvF0CQ3Ma@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Andy King <acking@vmware.com>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <7528811.sQvF0CQ3Ma@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/27/2013 9:31 AM, Paul Moore wrote:
> On Wednesday, February 27, 2013 08:51:50 AM Casey Schaufler wrote:
>> On 2/27/2013 8:43 AM, Paul Moore wrote:
>>> On Tuesday, February 26, 2013 03:12:31 PM Casey Schaufler wrote:
>>>> On 2/26/2013 1:21 PM, Paul Moore wrote:
>>>>> On Monday, February 25, 2013 03:06:14 PM Casey Schaufler wrote:
>>>>>> The set of LSMs, the order they are invoked, which LSM
>>>>>> uses /proc/.../attr/current and which LSM uses Netlabel,
>>>>>> XFRM and secmark are all determined by Kconfig. You can
>>>>>> specify a limited set of LSMs using security= at boot,
>>>>>> but not the networking configuration.
>>>>> That's unfortunate.  I'm _really_ not in favor of that, I would much
>>>>> rather see the non-shared LSM functionality assigned at the same time as
>>>>> the stacking order.  I'm not sure I'd NACK the current approach, or
>>>>> even\
>>>>> if anyone would care that I did, but that is how I'm currently leaning
>>>>> with this split (build vs runtime) selection.
>>>> I'm not against that approach. How would you see it working?
>>>>
>>>> The distro compiles in all the LSMs.
>>>> They specify that SELinux gets xfrm and secmark.
>>>> They specify the Smack gets Netlabel.
>>>> They tell (the new and improved) AppArmor to eschew networking.
>>>> They specify a boot order of "selinux,smack,apparmor,yama"
>>>> (They left off tomoyo for tax purposes).
>>>>
>>>> On the boot line, the user types "security=apparmor".
>>>>
>>>> What should happen?
>>> Okay, I misunderstood what was specified at boot time; I thought the
>>> stacking order could be defined at boot but based on your example I'm
>>> guessing the stacking order is defined at compile time and you can only
>>> enable/disable LSMs at boot?
>> Well, no. It looks as if I gave a poor example.
>>
>> 	"security=apparmor,tomoyo,selinux"
>>
>> is legitimate and indicates that AppArmor goes first,
>> then TOMOYO, then SELinux. No LSM gets NetLabel because
>> that was allocated to Smack. SELinux gets XFRM and secmark.
> All the more reason to either adopt a mechanism that allows you to assign the 
> non-shareable resources on the command line along with the stacking 
> configuration or simply adopt a first-come-first-serve policy.

I will think on this. I'm not sure I'll be happy however it ends up.

