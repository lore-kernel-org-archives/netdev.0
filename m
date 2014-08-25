From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V4 3/8] namespaces: expose ns instance serial numbers
 in proc
Date: Mon, 25 Aug 2014 15:30:46 +0200
Message-ID: <53FB3A86.2060203@6wind.com>
References: <cover.1408581429.git.rgb@redhat.com>	<cd6cd0622ce677b639afae18a69ff79c72490bab.1408581429.git.rgb@redhat.com>	<CALCETrUnzG1V8w+H9ctAJP+Hvo8LQax=dhLG4bBpBKmVi+C1cQ@mail.gmail.com>	<20140822015803.GG20529@madcap2.tricolour.ca> <CALCETrUkFD0iNi1SV_6ypN5Kf4GYybT5tzjRjRQuLzT9iBnQAg@mail.gmail.com>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrUkFD0iNi1SV_6ypN5Kf4GYybT5tzjRjRQuLzT9iBnQAg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 24/08/2014 19:52, Andy Lutomirski a =E9crit :
> On Thu, Aug 21, 2014 at 6:58 PM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> =
wrote:
>> On 14/08/21, Andy Lutomirski wrote:
>>> On Aug 20, 2014 8:12 PM, "Richard Guy Briggs" <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrot=
e:
>>>> Expose the namespace instace serial numbers in the proc filesystem=
 at
>>>> /proc/<pid>/ns/<ns>_snum.  The link text gives the serial number i=
n hex.
>>>
>>> What's the use case?
>>>
>>> I understand the utility of giving unique numbers to the audit code=
,
>>> but I don't think this part is necessary for that, and I'd like to
>>> understand what else will use this before committing to a duplicati=
ve
>>> API like this.
>>
>> How does a container manager get those numbers?  It could provoke a =
task
>> to cause an audit event that emits a NS_INFO message, or it could ru=
n a
>> task in that container to report its namespace serial numbers direct=
ly
>> from its /proc mount.
>
> Why does a container manager need them?  Is there any reason that
> keeping them entirely contained within the audit system would be a
> problem?
>
>>
>> The discussion in this thread touches on the use cases:
>>          https://lkml.org/lkml/2014/4/22/662
>>
>>> Note that this API is thoroughly incompatible with CRIU.  If we do
>>> this, someone will ask for a namespace number namespace, and that w=
ay
>>> lies madness.
>>
>> I had a very brief look at CRIU, but not enough to understand the is=
sue.
>> Others have hinted at this problem.
>>
>> Do you have a suggestion of a different approach that would be
>> compatible with CRIU?
>>
>> I'd originally considered some sort of UUID that would be globally
>> unique, but that would be very hard to devise or guarantee, and besi=
des,
>> namespaces aren't only used by containers and could be shared in oth=
er
>> ways.  Tracking the usage and migration of namespaces should be the =
task
>> of an upper layer.
>>
>
> CRIU wants to save the complete state of a namespace and then restore
> it.  For that to work, any information exposed to things in the
> namespace *cannot* be globally unique or unique per boot, since CRIU
> needs to arrange for that information to match whatever it was when
> CRIU saved it.
How are ifindex of network devices managed? These ifindexes are unique =
per boot,
thus can change depending on the order in which netdev are created.
These ifindexes are unique per boot and exposed to userspace ...

>
> Also, I think that code running in a namespace has no business even
> knowing a unique identity of that namespace from the perspective of
> the host.
Another scenario is when you have virtual network devices across two ne=
tns. You
need to identify the peer netns to have a netlink message which is full=
y=20
interpretable by the userspace.


Regards,
Nicolas
