From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Thu, 25 Aug 2011 14:55:39 +0200
Message-ID: <4E56464B.4070304@monom.org>
References: <4E558137.5020900@parallels.com> <m1k4a2qqew.fsf@fess.ebiederm.org>
	<4E55A55B.8090608@parallels.com>
	<20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com>
	<m14o16qlq1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m14o16qlq1.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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

Hi

On 08/25/2011 04:16 AM, Eric W. Biederman wrote:
> KAMEZAWA Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>  writes:
>
>> On Wed, 24 Aug 2011 22:28:59 -0300
>> Glauber Costa<glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  wrote:
>>
>>> On 08/24/2011 09:35 PM, Eric W. Biederman wrote:
>>>> Glauber Costa<glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>   writes:
>>> Hi Eric,
>>>
>>> Thanks for your attention.
>>>
>>> So, this that you propose was my first implementation. I ended up
>>> throwing it away after playing with it for a while.
>>>
>>> One of the first problems that arise from that, is that the sysctls are
>>> a tunable visible from inside the container. Those limits, however, are
>>> to be set from the outside world. The code is not much better than that
>>> either, and instead of creating new cgroup structures and linking them
>>> to the protocol, we end up doing it for net ns. We end up increasing
>>> structures just the same...
>
> You don't need to add a netns member to sockets.
>
> But I do agree that there are odd permission issues with using the
> existing sysctls and making them per namespace.
>
> However almost everything I have seen with memory limits I have found
> very strange.  They all seem like a very bad version of disabling memory
> over commits.

Please apply the same rules for not cursing my family no further then 
the 3rd generation for my idea:

I'd like to solve a use case where it is necessary to count all bytes 
transmitted and received by an application [1]. So far I have found two 
unsatisfying solution for it. The first one is to hook into libc and 
count the bytes there. I don't think I have to say I don't like this.

The second idea was to use the trick Google has used for Android [2]. 
They add a hook into __sock_sendmsg and __sock_recvmsg and then count 
the bytes per UID. To get this working all application have to use an 
unique UID. So not very nice either.

After reading a bit up on cgroup I think that would be the right place 
to count the traffic. Unfortunately, with net_cls I can count the 
outgoing traffic but not the incoming one. If I understood Glauber 
approach correctly adding some statistic counters would be easy to do. 
Of course I don't know the impact of this.

thanks,
daniel


[1] 
http://lists.freedesktop.org/archives/systemd-devel/2011-August/003093.html

[2] 
http://xf.iksaif.net/dev/android/android-2.6.29-to-2.6.32/0083-uidstat-Adding-uid-stat-driver-to-collect-network-st.patch
