From: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Fri, 15 May 2015 09:19:19 -0400
Message-ID: <5555F257.3030906@redhat.com>
References: <cover.1429252659.git.rgb@redhat.com>
	<2487286.y6vyJ9A3er@x2>	<20150512195759.GA9832@madcap2.tricolour.ca>	<2918460.dpKocsKt4o@x2>	<20150515004855.GB10526@madcap2.tricolour.ca>	<CAA4jN2bgynVTwF+owtXgq06JMLQJpy_qokpD0mAguNYeDxmh1A@mail.gmail.com>
	<20150515021126.GA965@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150515021126.GA965-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 05/14/2015 10:11 PM, Richard Guy Briggs wrote:
> On 15/05/14, Oren Laadan wrote:
>> On Thu, May 14, 2015 at 8:48 PM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>
>>>>>> Recording each instance of a name space is giving me something that I
>>>>>> cannot use to do queries required by the security target. Given these
>>>>>> events, how do I locate a web server event where it accesses a
>>> watched
>>>>>> file? That authentication failed? That an update within the container
>>>>>> failed?
>>>>>>
>>>>>> The requirements are that we have to log the creation, suspension,
>>>>>> migration, and termination of a container. The requirements are not
>>> on
>>>>>> the individual name space.
>>>>> Ok.  Do we have a robust definition of a container?
>>>> We call the combination of name spaces, cgroups, and seccomp rules a
>>>> container.
>>> Can you detail what information is required from each?
>>>
>>>>> Where is that definition managed?
>>>> In the thing that invokes a container.
>>> I was looking for a reference to a standards document rather than an
>>> application...
>>>
>>>
>> [focusing on "containers id" - snipped the rest away]
>>
>> I am unfamiliar with the audit subsystem, but work with namespaces in other
>> contexts. Perhaps the term "container" is overloaded here. The definition
>> suggested by Steve in this thread makes sense to me: "a combination of
>> namespaces". I imagine people may want to audit subsets of namespaces.
> I assume it would be a bit more than that, including cgroup and seccomp info.
I don't see why seccomp versus other Security mechanism come into this. 
Not really
sure of cgroup.  That stuff would all be associated with the process.  I
would guess
you could look at the process that modified these for logging, but that
should happen
at the time they get changed,  Not recorded for every process.
>> For namespaces, can use a string like "A:B:C:D:E:F" as an identifier for a
>> particular combination, where A-F are respective namespaces identifiers.
>> (Can be taken for example from /proc/PID/ns/{mnt,uts,ipc,user,pid,net}).
>>  That will even be grep-able to locate records related to a particular
>> subset
>> of namespaces. So a "container" in the classic meaning would have all A-F
>> unique and different from the init process, but processes separated only by
>> e.g. mnt-ns and net-ns will differ from the init process in  A and F.
>>
>> (If a string is a no go, then perhaps combine the IDs in a unique way into a
>> super ID).
> I'd be fine with either, even including the nsfs deviceID.
>
>> Oren.
> - RGB
>
> --
> Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
> Remote, Ottawa, Canada
> Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
>
> --
> Linux-audit mailing list
> Linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
> https://www.redhat.com/mailman/listinfo/linux-audit
