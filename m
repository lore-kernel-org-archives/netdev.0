From: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: skip genenerating uevents for network namespaces
	that are exiting
Date: Mon, 24 Oct 2016 10:17:12 -0700
Message-ID: <CAM_iQpUznmhpZ=N5_x5AD_DivdEFcLJKV69br12fv2zpd4sqjQ@mail.gmail.com>
References: <1477017986-18889-1-git-send-email-avagin@openvz.org>
	<CAM_iQpVA=W3su_a3OUVSD+19A72TMANnCX4dt9UyLOmVoRuBjQ@mail.gmail.com>
	<CANaxB-zo4YW7o-Ebe08B_L_f8Wyp6tMWc-rBRt8-4sSc1Y=tgg@mail.gmail.com>
	<CANaxB-wvJsts7RUEg1pouD0xMLTQAoVMaWaXZ2wLFT9XE1E1Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CANaxB-wvJsts7RUEg1pouD0xMLTQAoVMaWaXZ2wLFT9XE1E1Mw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Sat, Oct 22, 2016 at 12:37 AM, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> Hi Cong,
>
> On Thu, Oct 20, 2016 at 10:25 PM, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>> On Thu, Oct 20, 2016 at 8:10 PM, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> On Thu, Oct 20, 2016 at 7:46 PM, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>>>> No one can see these events, because a network namespace can not be
>>>> destroyed, if it has sockets.
>>>>
>>>
>>> Are you sure? kobject_uevent_env() seems sending uevents to all
>>> network namespaces.
>>
>> kobj_bcast_filter() checks that a kobject namespace is equal to a
>> socket namespace.
>
> Today I've checked that it really works as I read from the source code.
> I use this tool to read events:
> https://gist.github.com/avagin/430ba431fc2972002df40ebe6a048b36
>
> And I see that events from non-network devices are delivered to all sockets,
> but events from network devices are delivered only to sockets from
> a network namespace where a device is operated.

I missed it, it makes sense now. Please consider adding a comment in
the code or expanding your changelog for reference.

Thanks!
