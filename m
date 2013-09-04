From: =?windows-1252?Q?Jan_Kalu=9Ea?= <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 0/3] Send audit/procinfo/cgroup data in socket-level
 control message
Date: Wed, 04 Sep 2013 17:04:00 +0200
Message-ID: <52274BE0.7060501@redhat.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com> <1378275261-4553-1-git-send-email-jkaluza@redhat.com> <878uzdf2xp.fsf@xmission.com> <20130904145830.GC28517@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130904145830.GC28517-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/04/2013 04:58 PM, Richard Guy Briggs wrote:
> On Wed, Sep 04, 2013 at 12:42:26AM -0700, Eric W. Biederman wrote:
>> Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>>> Hi,
>>>
>>> this patchset against net-next (applies also to linux-next) adds 3 new types
>>> of "Socket"-level control message (SCM_AUDIT, SCM_PROCINFO and SCM_CGROUP).
>>>
>>> Server-like processes in many cases need credentials and other
>>> metadata of the peer, to decide if the calling process is allowed to
>>> request a specific action, or the server just wants to log away this
>>> type of information for auditing tasks.
>>>
>>> The current practice to retrieve such process metadata is to look that
>>> information up in procfs with the $PID received over SCM_CREDENTIALS.
>>> This is sufficient for long-running tasks, but introduces a race which
>>> cannot be worked around for short-living processes; the calling
>>> process and all the information in /proc/$PID/ is gone before the
>>> receiver of the socket message can look it up.
>>
>>> Changes introduced in this patchset can also increase performance
>>> of such server-like processes, because current way of opening and
>>> parsing /proc/$PID/* files is much more expensive than receiving these
>>> metadata using SCM.
>>
>> Can I just say ick, blech, barf, gag.
>
> /me hands ebiederman an air sickness bag.
>
>> You don't require this information to be passed.  You are asking people
>> to suport a lot of new code for the forseeable future.  The only advantage
>> appears to be for short lived racy processes that don't even bother to
>> make certain their message was acknowleged before exiting.
>>
>> You sent this during the merge window which is the time for code
>> integration and testing not new code.
>
> This is an RFC.  How is this important?
>
>> By my count you have overflowed cb in struct sk_buff and are stomping on
>> _skb_refdest.
>
> For patch1/3 I count 56/48, then for patch3 I get 48/48.  Jan, you might
> do the conversion to a pointer in patch1/3 to avoid bisect breakage.

Yes, this is valid point. I will do the conversion in patch1. Thanks all 
for reviewing and pointing that out.

Jan Kaluza

>> If you are going to go crazy and pass things is there a reason you do
>> not add a patch to pass the bsd SCM_CREDS?  That information seems more
>> relevant in a security context and for making security decisions than
>> about half the information you are passing.
>>
>> Eric
>
> - RGB
>
> --
> Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Senior Software Engineer
> Kernel Security
> AMER ENG Base Operating Systems
> Remote, Ottawa, Canada
> Voice: +1.647.777.2635
> Internal: (81) 32635
> Alt: +1.613.693.0684x3545
>
